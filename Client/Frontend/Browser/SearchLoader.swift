// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import Storage
import Glean
import Common

private let URLBeforePathRegex = try? NSRegularExpression(pattern: "^https?://([^/]+)/", options: [])

/**
 * Shared data source for the SearchViewController and the URLBar domain completion.
 * Since both of these use the same SQL query, we can perform the query once and dispatch the results.
 */
class SearchLoader: Loader<Cursor<Site>, SearchViewController>, FeatureFlaggable {
    fileprivate let profile: Profile
    fileprivate let urlBar: URLBarView
    private let logger: Logger

    private var skipNextAutocomplete: Bool

    init(profile: Profile, urlBar: URLBarView, logger: Logger = DefaultLogger.shared) {
        self.profile = profile
        self.urlBar = urlBar
        self.skipNextAutocomplete = false
        self.logger = logger

        super.init()
    }

    fileprivate lazy var topDomains: [String]? = {
        guard let filePath = Bundle.main.path(forResource: "topdomains", ofType: "txt")
        else { return nil }

        return try? String(contentsOfFile: filePath).components(separatedBy: "\n")
    }()

    fileprivate func getBookmarksAsSites(matchingSearchQuery query: String, limit: UInt, completionHandler: @escaping (([Site]) -> Void)) {
        profile.places.searchBookmarks(query: query, limit: limit).upon { result in
            guard let bookmarkItems = result.successValue else {
                completionHandler([])
                return
            }

            let sites = bookmarkItems.map({ Site(url: $0.url, title: $0.title, bookmarked: true, guid: $0.guid) })
            completionHandler(sites)
        }
    }

    var query: String = "" {
        didSet {
            let timerid = GleanMetrics.Awesomebar.queryTime.start()
            guard profile is BrowserProfile else {
                assertionFailure("nil profile")
                GleanMetrics.Awesomebar.queryTime.cancel(timerid)
                return
            }

            if query.isEmpty {
                load(Cursor(status: .success, msg: "Empty query"))
                GleanMetrics.Awesomebar.queryTime.cancel(timerid)
                return
            }

            getBookmarksAsSites(matchingSearchQuery: query, limit: 5) { [weak self] bookmarks in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let results = [bookmarks]
                    defer {
                        GleanMetrics.Awesomebar.queryTime.stopAndAccumulate(timerid)
                    }

                    let bookmarksSites = results[safe: 0] ?? []

                    // Load the data in the table view.
                    self.load(ArrayCursor(data: bookmarksSites))

                    // If the new search string is not longer than the previous
                    // we don't need to find an autocomplete suggestion.
                    guard oldValue.count < self.query.count else { return }

                    // If we should skip the next autocomplete, reset
                    // the flag and bail out here.
                    guard !self.skipNextAutocomplete else {
                        self.skipNextAutocomplete = false
                        return
                    }

                    // First, see if the query matches any URLs from the user's search history.
                    for site in bookmarksSites {
                        if let completion = self.completionForURL(site.url) {
                            self.urlBar.setAutocompleteSuggestion(completion)
                            return
                        }
                    }

                    // If there are no search history matches, try matching one of the Alexa top domains.
                    if let topDomains = self.topDomains {
                        for domain in topDomains {
                            if let completion = self.completionForDomain(domain) {
                                self.urlBar.setAutocompleteSuggestion(completion)
                                return
                            }
                        }
                    }
                }
            }
        }
    }

    func setQueryWithoutAutocomplete(_ query: String) {
        skipNextAutocomplete = true
        self.query = query
    }

    fileprivate func completionForURL(_ url: String) -> String? {
        // Extract the pre-path substring from the URL. This should be more efficient than parsing via
        // NSURL since we need to only look at the beginning of the string.
        // Note that we won't match non-HTTP(S) URLs.
        guard let match = URLBeforePathRegex?.firstMatch(
            in: url,
            options: [],
            range: NSRange(location: 0, length: url.count))
        else { return nil }

        // If the pre-path component (including the scheme) starts with the query, just use it as is.
        var prePathURL = (url as NSString).substring(with: match.range(at: 0))
        if prePathURL.hasPrefix(query) {
            // Trailing slashes in the autocompleteTextField cause issues with Swipe keyboard. Bug 1194714
            if prePathURL.hasSuffix("/") {
                prePathURL.remove(at: prePathURL.index(before: prePathURL.endIndex))
            }
            return prePathURL
        }

        // Otherwise, find and use any matching domain.
        // To simplify the search, prepend a ".", and search the string for ".query".
        // For example, for http://en.m.wikipedia.org, domainWithDotPrefix will be ".en.m.wikipedia.org".
        // This allows us to use the "." as a separator, so we can match "en", "m", "wikipedia", and "org",
        let domain = (url as NSString).substring(with: match.range(at: 1))
        return completionForDomain(domain)
    }

    fileprivate func completionForDomain(_ domain: String) -> String? {
        let domainWithDotPrefix: String = ".\(domain)"
        if let range = domainWithDotPrefix.range(of: ".\(query)", options: .caseInsensitive, range: nil, locale: nil) {
            // We don't actually want to match the top-level domain ("com", "org", etc.) by itself, so
            // so make sure the result includes at least one ".".
            let matchedDomain = String(domainWithDotPrefix[domainWithDotPrefix.index(range.lowerBound, offsetBy: 1)...])
            if matchedDomain.contains(".") {
                return matchedDomain
            }
        }

        return nil
    }
}
