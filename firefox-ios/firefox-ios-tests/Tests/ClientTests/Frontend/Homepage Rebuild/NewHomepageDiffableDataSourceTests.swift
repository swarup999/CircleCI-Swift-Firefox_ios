// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

@testable import Client

final class NewHomepageDiffableDataSourceTests: XCTestCase {
    var diffableDataSource: NewHomepageDiffableDataSource?

    override func setUp() {
        super.setUp()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        diffableDataSource = NewHomepageDiffableDataSource(
            collectionView: collectionView
        ) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return UICollectionViewCell()
        }
    }
    // MARK: - applyInitialSnapshot
    func test_applyInitialSnapshot_hasCorrectData() {
        diffableDataSource?.applyInitialSnapshot()
        diffableDataSource?.applyInitialSnapshot()
        let snapshot = diffableDataSource?.snapshot()

        XCTAssertEqual(snapshot?.numberOfSections, 3)
        XCTAssertEqual(snapshot?.sectionIdentifiers, [.header, .topSites, .pocket])
    }

    private func createSubject() -> NewHomepageDiffableDataSource {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        let diffableDataSource = NewHomepageDiffableDataSource(
            collectionView: collectionView
        ) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return UICollectionViewCell()
        }

        trackForMemoryLeaks(diffableDataSource)
        return diffableDataSource
    }
}
