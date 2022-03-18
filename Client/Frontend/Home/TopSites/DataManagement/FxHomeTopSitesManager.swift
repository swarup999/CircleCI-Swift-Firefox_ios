// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import Storage

protocol FxHomeTopSitesManagerDelegate: AnyObject {
    func reloadTopSites()
}

class FxHomeTopSitesManager: FeatureFlagsProtocol {

    private let googleTopSiteManager: GoogleTopSiteManager
    private let profile: Profile

    private var topSites: [HomeTopSite] = []
    private let dataQueue = DispatchQueue(label: "com.moz.topSitesManager.queue")

    // Raw data to build top sites with
    private var historySites: [Site] = []
    private var contiles: [Contile] = []

    weak var delegate: FxHomeTopSitesManagerDelegate?
    lazy var topSiteHistoryManager = TopSiteHistoryManager(profile: profile)
    lazy var contileProvider: ContileProvider = ContileProviderMock(successData: ContileProviderMock.mockSuccessData)
    
    init(profile: Profile) {
        self.profile = profile
        self.googleTopSiteManager = GoogleTopSiteManager(prefs: profile.prefs)
        topSiteHistoryManager.delegate = self
    }

    func getSite(index: Int) -> HomeTopSite? {
        guard !topSites.isEmpty, index < topSites.count, index >= 0 else { return nil }
        return topSites[index]
    }

    func getSiteDetail(index: Int) -> Site? {
        guard !topSites.isEmpty, index < topSites.count, index >= 0 else { return nil }
        return topSites[index].site
    }

    var hasData: Bool {
        return !historySites.isEmpty
    }

    var siteCount: Int {
        return historySites.count
    }

    func removePinTopSite(site: Site) {
        googleTopSiteManager.removeGoogleTopSite(site: site)
        topSiteHistoryManager.removeTopSite(site: site)
    }

    func refreshIfNeeded(forceTopSites: Bool) {
        topSiteHistoryManager.refreshIfNeeded(forceTopSites: forceTopSites)
    }

    // MARK: - Data loading

    // Loads the data source of top sites
    func loadTopSitesData(dataLoadingCompletion: (() -> Void)? = nil) {
        let group = DispatchGroup()
        loadContiles(group: group)
        loadTopSites(group: group)

        group.notify(queue: dataQueue) {
            dataLoadingCompletion?()
        }
    }

    private func loadContiles(group: DispatchGroup) {
        group.enter()
        contileProvider.fetchContiles { result in
            if case .success(let contiles) = result {
                self.contiles = contiles
            }
            group.leave()
        }
    }

    private func loadTopSites(group: DispatchGroup) {
        group.enter()
        topSiteHistoryManager.getTopSites { sites in
            self.historySites = sites
            group.leave()
        }
    }

    // MARK: - Tiles placement calculation

    /// Top sites are composed of pinned sites, history, Contiles and Google top site.
    /// Google top site is always first, then comes the contiles, pinned sites and history top sites.
    /// We only add Google top site or Contiles if number of pins doesn't exeeds the available number shown of tiles.
    /// - Parameter numberOfTilesPerRow: The number of tiles per row shown to the user
    func calculateTopSiteData(numberOfTilesPerRow: Int) {
        var sites = historySites
        let pinnedSiteCount = countPinnedSites(sites: sites)
        let totalNumberOfShownTiles = numberOfTilesPerRow * numberOfRows
        let availableSpacesCount = totalNumberOfShownTiles - pinnedSiteCount

        addSponsoredTiles(sites: &sites, availableSpacesCount: availableSpacesCount)
        addGoogleTopSite(sites: &sites, availableSpacesCount: availableSpacesCount)

        topSites = sites.map { HomeTopSite(site: $0, profile: profile) }

        // Refresh data in the background so we'll have fresh data next time we show
        refreshIfNeeded(forceTopSites: false)
    }

    // The number of rows the user wants.
    // If there is no preference, the default is used.
    var numberOfRows: Int {
        let preferredNumberOfRows = profile.prefs.intForKey(PrefsKeys.NumberOfTopSiteRows)
        let defaultNumberOfRows = TopSitesRowCountSettingsController.defaultNumberOfRows
        return Int(preferredNumberOfRows ?? defaultNumberOfRows)
    }

    private func addSponsoredTiles(sites: inout [Site], availableSpacesCount: Int) {
        guard shouldShowSponsoredTiles else { return }

        // Google tile has precedence over Sponsored Tiles
        let sponsoredTileSpaces = availableSpacesCount - GoogleTopSiteManager.Constants.reservedSpaceCount
        if sponsoredTileSpaces > 0 {
            addSponsoredTiles(sponsoredTileSpaces: sponsoredTileSpaces, sites: &sites)
        }
    }

    private func addGoogleTopSite(sites: inout [Site], availableSpacesCount: Int) {
        guard googleTopSiteManager.shouldAddGoogleTopSite(availableSpacesCount: availableSpacesCount) else { return }
        googleTopSiteManager.addGoogleTopSite(sites: &sites)
    }

    private func countPinnedSites(sites: [Site]) -> Int {
        var pinnedSites = 0
        sites.forEach {
            if let _ = $0 as? PinnedSite { pinnedSites += 1 }
        }
        return pinnedSites
    }

    // MARK: - Sponsored tiles (Contiles)

    static let maximumNumberOfSponsoredTile = 1

    // TODO: Check for settings user preference with https://mozilla-hub.atlassian.net/browse/FXIOS-3469
    // TODO: Check for nimbus with https://mozilla-hub.atlassian.net/browse/FXIOS-3468
    private var shouldShowSponsoredTiles: Bool {
        return !contiles.isEmpty && featureFlags.isFeatureActiveForBuild(.sponsoredTiles)
    }

    /// Add sponsored tiles to the top sites.
    /// - Parameters:
    ///   - sponsoredTileSpaces: The number of spaces available for sponsored tiles
    ///   - sites: The top sites to add the sponsored tile to
    private func addSponsoredTiles(sponsoredTileSpaces: Int, sites: inout [Site]) {
        var siteAdded = 0
        for index in (0..<FxHomeTopSitesManager.maximumNumberOfSponsoredTile) {

            guard siteAdded < sponsoredTileSpaces else { return }
            let site = SponsoredTile(contile: contiles[index])

            // Show the next sponsored site if site is already present in the pinned sites
            guard !siteIsAlreadyPresent(site: site, in: sites) else { continue }

            sites.insert(site, at: 0)
            siteAdded += 1
        }
    }

    // Check to ensure a site isn't already existing in the pinned top sites
    private func siteIsAlreadyPresent(site: Site, in sites: [Site]) -> Bool {
        return sites.filter { $0.url == site.url && (site as? PinnedSite) == nil }.count > 0
    }
}

extension FxHomeTopSitesManager: DataObserverDelegate {

    func didInvalidateDataSources(refresh forced: Bool, topSitesRefreshed: Bool) {
        guard forced else { return }
        delegate?.reloadTopSites()
    }
}
