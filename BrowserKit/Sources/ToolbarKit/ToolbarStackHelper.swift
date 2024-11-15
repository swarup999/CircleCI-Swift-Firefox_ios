// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Common

protocol ToolbarStackHelper {
    func newOrExistingToolbarButton(for element: ToolbarElement,
                                    existingButtons: [ToolbarButton]) -> ToolbarButton
}

extension ToolbarStackHelper {
    func newOrExistingToolbarButton(for element: ToolbarElement,
                                    existingButtons: [ToolbarButton]) -> ToolbarButton {
        let existingButton = existingButtons.first { $0.isButtonFor(toolbarElement: element) }

        guard let existingButton else {
            return element.numberOfTabs != nil ? TabNumberButton() : ToolbarButton()
        }

        return existingButton
    }
}
