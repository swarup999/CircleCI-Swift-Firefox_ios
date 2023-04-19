// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import CoreSpotlight

/// An enumeration representing different navigational routes in an application.
enum Route: Equatable {
    /// Represents a search route that takes a URL and a boolean value indicating whether the search is private or not.
    ///
    /// - Parameters:
    ///   - url: A `URL` object representing the URL to be searched. Can be `nil`.
    ///   - isPrivate: A boolean value indicating whether the search is private or not.
    case search(url: URL?, isPrivate: Bool)

    /// Represents a search route that takes a URL and a tab identifier.
    ///
    /// - Parameters:
    ///   - url: A `URL` object representing the URL to be searched. Can be `nil`.
    ///   - tabId: A string representing the identifier of the tab where the search should be performed.
    case search(url: URL?, tabId: String)

    /// Represents a search route that takes a query string.
    ///
    /// - Parameter query: A string representing the query to be searched.
    case search(query: String)

    /// Represents a route for sending Glean data.
    ///
    /// - Parameter url: A `URL` object representing the URL to send Glean data to.
    case glean(url: URL)

    /// Represents a home panel route that takes a `HomepanelSection` value indicating the section to be displayed.
    ///
    /// - Parameter section: An instance of `HomepanelSection` indicating the section of the home panel to be displayed.
    case homepanel(section: HomepanelSection)

    /// Represents a settings route that takes a `SettingsSection` value indicating the settings section to be displayed.
    ///
    /// - Parameter section: An instance of `SettingsSection` indicating the section of the settings menu to be displayed.
    case settings(section: SettingsSection)

    /// Represents an application action route that takes an `AppAction` value indicating the action to be performed.
    ///
    /// - Parameter action: An instance of `AppAction` indicating the application action to be performed.
    case action(action: AppAction)

    /// Represents a Firefox account sign-in route that takes an `FxALaunchParams` object indicating the parameters for the sign-in.
    ///
    /// - Parameter params: An instance of `FxALaunchParams` containing the parameters for the sign-in.
    case fxaSignIn(_ params: FxALaunchParams)

    /// Represents a default browser route that takes a `DefaultBrowserSection` value indicating the section to be displayed.
    ///
    /// - Parameter section: An instance of `DefaultBrowserSection` indicating the section of the default browser settings to be displayed.
    case defaultBrowser(section: DefaultBrowserSection)

    /// An enumeration representing different sections of the home panel.
    enum HomepanelSection: String, CaseIterable, Equatable {
        case bookmarks
        case topSites = "top-sites"
        case history
        case readingList = "reading-list"
        case downloads
    }

    /// An enumeration representing different sections of the settings menu.
    enum SettingsSection: String, CaseIterable, Equatable {
        case clearPrivateData = "clear-private-data"
        case newTab = "newtab"
        case homePage = "homepage"
        case mailto
        case search
        case fxa
        case systemDefaultBrowser = "system-default-browser"
        case wallpaper
        case theme
        case contentBlocker
        case toolbar
        case tabs
        case topSites
        case general
    }

    /// An enumeration representing different actions that can be performed within the application.
    enum AppAction: String, CaseIterable, Equatable {
        case closePrivateTabs = "close-private-tabs"
        case presentDefaultBrowserOnboarding
        case showQRCode
    }

    /// An enumeration representing different sections of the default browser settings.
    enum DefaultBrowserSection: String, CaseIterable, Equatable {
        case tutorial
        case systemSettings = "system-settings"
    }

    init?(userActivity: NSUserActivity) {
        // If the user activity is a Siri shortcut to open the app, show a new search tab.
        if userActivity.activityType == SiriShortcuts.activityType.openURL.rawValue {
            self = .search(url: nil, isPrivate: false)
            return
        }

        // If the user activity has a webpageURL, it's a deep link or an old history item.
        // Use the URL to create a new search tab.
        if let url = userActivity.webpageURL {
            self = .search(url: url, isPrivate: false)
            return
        }

        // If the user activity is a CoreSpotlight item, check its activity identifier to determine
        // which URL to open.
        if userActivity.activityType == CSSearchableItemActionType {
            guard let userInfo = userActivity.userInfo,
                  let urlString = userInfo[CSSearchableItemActivityIdentifier] as? String,
                  let url = URL(string: urlString)
            else {
                return nil
            }
            self = .search(url: url, isPrivate: false)
            return
        }

        // If the user activity does not match any of the above criteria, return nil to indicate that
        // the route could not be determined.
        return nil
    }
}
