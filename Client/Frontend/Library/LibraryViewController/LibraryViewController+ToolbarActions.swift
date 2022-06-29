// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// MARK: - Toolbar Button Actions
extension LibraryViewController {

    @objc func topLeftButtonAction() {
        guard let navController = children.first as? UINavigationController,
              let panel = viewModel.getCurrentPanel() else { return }

        panel.handleBackButton()
        navController.popViewController(animated: true)
    }

    @objc func topRightButtonAction() {
        guard let panel = viewModel.getCurrentPanel() else { return }

        if panel.shouldDismissOnDone() {
            dismiss(animated: true, completion: nil)
        }

        panel.handleDoneButton()
    }
}
