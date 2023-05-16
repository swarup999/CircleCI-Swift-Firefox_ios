// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

protocol OnboardingViewControllerProtocol {
    var pageController: UIPageViewController { get }
    var pageControl: UIPageControl { get }
    var viewModel: OnboardingViewModelProtocol { get }
    var didFinishFlow: (() -> Void)? { get }

    func getNextOnboardingCard(index: Int, goForward: Bool) -> OnboardingCardViewController?
    func moveToNextPage(from cardNamed: String)
    func getCardIndex(viewController: OnboardingCardViewController) -> Int?
    func showNextPage(from cardNamed: String, completionIfLastCard completion: () -> Void)
}

extension OnboardingViewControllerProtocol {
    func showNextPage(
        from cardName: String,
        completionIfLastCard completion: () -> Void
    ) {
        guard cardName != viewModel.availableCards.last?.viewModel.infoModel.name else {
            completion()
            return
        }

        moveToNextPage(from: cardName)
    }

    func getNextOnboardingCard(index: Int, goForward: Bool) -> OnboardingCardViewController? {
        guard let index = viewModel.getNextIndex(currentIndex: index, goForward: goForward) else { return nil }

        return viewModel.availableCards[index]
    }

    func moveToNextPage(from cardName: String) {
        if let index = viewModel.availableCards
            .firstIndex(where: { $0.viewModel.infoModel.name == cardName }),
           let nextViewController = getNextOnboardingCard(index: index, goForward: true) {
            pageControl.currentPage = index + 1
            pageController.setViewControllers(
                [nextViewController],
                direction: .forward,
                animated: false)
        }
    }

    // Due to restrictions with PageViewController we need to get the index of the current view controller
    // to calculate the next view controller
    func getCardIndex(viewController: OnboardingCardViewController) -> Int? {
        let cardName = viewController.viewModel.infoModel.name

        guard let index = viewModel.availableCards
            .firstIndex(where: { $0.viewModel.infoModel.name == cardName })
        else { return nil }

        return index
    }
}
