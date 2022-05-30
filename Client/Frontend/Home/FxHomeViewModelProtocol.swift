// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// Protocol for each section view model in Firefox Home page view controller
protocol FXHomeViewModelProtocol {

    var sectionType: FirefoxHomeSectionType { get }

    // Layout section so FirefoxHomeViewController view controller can setup the section
    var section: NSCollectionLayoutSection { get }

    var numberOfItemsInSection: Int { get }

    // The header view model to setup the header for this section
    var headerViewModel: ASHeaderViewModel { get }

    // Returns true when section needs to load data and show itself
    var isEnabled: Bool { get }

    // Returns true when section has data to show
    var hasData: Bool { get }

    // Returns true when section has data and is enabled
    var shouldShow: Bool { get }

    // Update section data, completes when data has finished loading
    func updateData(completion: @escaping () -> Void)

    // If we need to reload the section after data was loaded
    var shouldReloadSection: Bool { get }

    // Update section that are privacy sensitive, only implement when needed
    func updatePrivacyConcernedSection(isPrivate: Bool)
}

extension FXHomeViewModelProtocol {
    var hasData: Bool { return true }

    var shouldShow: Bool {
        return isEnabled && hasData
    }

    // TODO: Laurie
    var section: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        return NSCollectionLayoutSection(group: group)
    }

    var numberOfItemsInSection: Int {
        return 0
    }

    func updateData(completion: @escaping () -> Void) {}

    var shouldReloadSection: Bool { return false }

    func updatePrivacyConcernedSection(isPrivate: Bool) {}
}
