// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class ToolbarButton: UIButton {
    // MARK: - Variables

    var selectedTintColor: UIColor!
    var unselectedTintColor: UIColor!
    var disabledTintColor: UIColor!

    // Optionally can associate a separator line that hide/shows along with the button
    weak var separatorLine: UIView?

    override open var isHighlighted: Bool {
        didSet {
            self.tintColor = isHighlighted ? selectedTintColor : unselectedTintColor
        }
    }

    override open var isEnabled: Bool {
        didSet {
            self.tintColor = isEnabled ? unselectedTintColor : disabledTintColor
        }
    }

    override var tintColor: UIColor! {
        didSet {
            self.imageView?.tintColor = self.tintColor
        }
    }

    override var isHidden: Bool {
        didSet {
            separatorLine?.isHidden = isHidden
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustsImageWhenHighlighted = false
        selectedTintColor = tintColor
        unselectedTintColor = tintColor
        imageView?.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Theme protocols

extension ToolbarButton: ThemeApplicable {
    func applyTheme(theme: Theme) {
        selectedTintColor = theme.colors.actionPrimary
        disabledTintColor = theme.colors.iconDisabled
        unselectedTintColor = theme.colors.iconPrimary
        tintColor = isEnabled ? unselectedTintColor : disabledTintColor
        imageView?.tintColor = tintColor
    }
}
