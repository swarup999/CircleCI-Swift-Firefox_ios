// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

public enum WallpaperSettingsError: Error {
    case itemNotFound
}

class WallpaperSettingsViewModel {

    enum WallpaperSettingsLayout: Equatable {
        case compact
        case regular

        // The maximum number of items to display per row
        var itemsPerRow: Int {
            switch self {
            case .compact: return 3
            case .regular: return 4
            }
        }
    }

    struct Constants {
        struct Strings {
            struct Toast {
                static let label: String = .Settings.Homepage.Wallpaper.WallpaperUpdatedToastLabel
                static let button: String = .Settings.Homepage.Wallpaper.WallpaperUpdatedToastButton
            }
        }
    }

    private var wallpaperManager: WallpaperManagerInterface
    private var wallpaperCollections = [WallpaperCollection]()
    var tabManager: TabManager
    var sectionLayout: WallpaperSettingsLayout = .compact // We use the compact layout as default

    var numberOfSections: Int {
        return wallpaperCollections.count
    }

    init(wallpaperManager: WallpaperManagerInterface = WallpaperManager(), tabManager: TabManager) {
        self.wallpaperManager = wallpaperManager
        self.tabManager = tabManager
        setupWallpapers()
    }

    func numberOfWallpapers(in section: Int) -> Int {
        return wallpaperCollections[safe: section]?.wallpapers.count ?? 0
    }

    func sectionHeaderViewModel(for sectionIndex: Int, dismissView: @escaping (() -> Void)) -> WallpaperSettingsHeaderViewModel? {
        guard let collection = wallpaperCollections[safe: sectionIndex] else { return nil }

        let isClassic = collection.type == .classic
        let title: String = isClassic ?
            .Settings.Homepage.Wallpaper.ClassicWallpaper : .Settings.Homepage.Wallpaper.LimitedEditionWallpaper
        var description: String? = isClassic ? nil : .Settings.Homepage.Wallpaper.IndependentVoicesDescription
        let buttonTitle: String? = isClassic ? nil : .Settings.Homepage.Wallpaper.LearnMoreButton

        // the first limited edition collection has a different description, any other collection uses the default
        if sectionIndex > 1 {
            description = .Settings.Homepage.Wallpaper.LimitedEditionDefaultDescription
        }

        let buttonAction = { [weak self] in
            guard let strongSelf = self, let learnMoreUrl = collection.learnMoreUrl else { return }

            dismissView()
            let tab = strongSelf.tabManager.addTab(URLRequest(url: learnMoreUrl),
                                                   afterTab: strongSelf.tabManager.selectedTab,
                                                   isPrivate: false)
            strongSelf.tabManager.selectTab(tab)
        }

        let a11yIds = AccessibilityIdentifiers.Settings.Homepage.CustomizeFirefox.Wallpaper.self

        return WallpaperSettingsHeaderViewModel(
            title: title,
            titleA11yIdentifier: "\(a11yIds.collectionTitle)_\(sectionIndex)",
            description: description,
            descriptionA11yIdentifier: "\(a11yIds.collectionDescription)_\(sectionIndex)",
            buttonTitle: buttonTitle,
            buttonA11yIdentifier: "\(a11yIds.collectionButton)_\(sectionIndex)",
            buttonAction: buttonAction)
    }

    func updateSectionLayout(for traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .compact {
            sectionLayout = .compact
        } else {
            sectionLayout = .regular
        }
        setupWallpapers()
    }

    func cellViewModel(for indexPath: IndexPath) -> WallpaperCellViewModel? {
        guard let collection = wallpaperCollections[safe: indexPath.section],
                let wallpaper = collection.wallpapers[safe: indexPath.row] else {
            return nil
        }
        return cellViewModel(for: wallpaper,
                             collectionType: collection.type,
                             indexPath: indexPath)
    }

    func downloadAndSetWallpaper(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let collection = wallpaperCollections[safe: indexPath.section],
                let wallpaper = collection.wallpapers[safe: indexPath.row] else {
            completion(.failure(WallpaperSelectorError.itemNotFound))
            return
        }

        let setWallpaperBlock = { [weak self] in
            self?.updateCurrentWallpaper(for: wallpaper, in: collection) { result in
                completion(result)
            }
        }

        if wallpaper.needsToFetchResources {
            wallpaperManager.fetch(wallpaper) { result in
                switch result {
                case .success:
                    setWallpaperBlock()
                case .failure:
                    completion(result)
                }
            }
        } else {
            setWallpaperBlock()
        }
    }
}

private extension WallpaperSettingsViewModel {

    func setupWallpapers() {
        wallpaperCollections = wallpaperManager.availableCollections
    }

    func cellViewModel(for wallpaper: Wallpaper,
                       collectionType: WallpaperCollectionType,
                       indexPath: IndexPath
    ) -> WallpaperCellViewModel {
        let wallpaperA11yIds = AccessibilityIdentifiers.Settings.Homepage.CustomizeFirefox.Wallpaper.self
        let a11yId = "\(wallpaperA11yIds.card)_\(indexPath.section)_\(indexPath.row)"
        var a11yLabel: String

        switch collectionType {
        case .classic:
            a11yLabel = "\(String.Settings.Homepage.Wallpaper.ClassicWallpaper) \(indexPath.row + 1)"
        case .limitedEdition:
            a11yLabel = "\(String.Settings.Homepage.Wallpaper.LimitedEditionWallpaper) \(indexPath.row + 1)"
        }

        let cellViewModel = WallpaperCellViewModel(image: wallpaper.thumbnail,
                                                   a11yId: a11yId,
                                                   a11yLabel: a11yLabel,
                                                   isSelected: wallpaperManager.currentWallpaper == wallpaper)
        return cellViewModel
    }

    func updateCurrentWallpaper(for wallpaper: Wallpaper,
                                in collection: WallpaperCollection,
                                completion: @escaping (Result<Void, Error>) -> Void) {
        wallpaperManager.setCurrentWallpaper(to: wallpaper) { [weak self] result in
            self?.setupWallpapers()

            guard let extra = self?.telemetryMetadata(for: wallpaper, in: collection) else {
                completion(result)
                return
            }
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .wallpaperSettings,
                                         value: .wallpaperSelected,
                                         extras: extra)

           completion(result)
        }
    }

    func telemetryMetadata(for wallpaper: Wallpaper, in collection: WallpaperCollection) -> [String: String] {
        var metadata = [String: String]()

        metadata[TelemetryWrapper.EventExtraKey.wallpaperName.rawValue] = wallpaper.id

        let wallpaperTypeKey = TelemetryWrapper.EventExtraKey.wallpaperType.rawValue
        switch wallpaper.type {
        case .defaultWallpaper:
            metadata[wallpaperTypeKey] = "default"
        case .other:
            switch collection.type {
            case .classic:
                metadata[wallpaperTypeKey] = collection.type.rawValue
            case .limitedEdition:
                metadata[wallpaperTypeKey] = collection.id
            }
        }

        return metadata
    }
}
