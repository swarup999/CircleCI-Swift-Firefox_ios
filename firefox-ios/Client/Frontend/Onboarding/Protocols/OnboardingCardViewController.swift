// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Common
import ComponentLibrary

class OnboardingCardViewController: UIViewController, Themeable {
    // MARK: - Common UX Elements
    struct SharedUX {
        static let topStackViewSpacing: CGFloat = 24
        static let titleFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 28 : 22
        static let descriptionFontSize: CGFloat = 17

        // small device
        static let smallTitleFontSize: CGFloat = 20
        static let smallStackViewSpacing: CGFloat = 8
        static let smallScrollViewVerticalPadding: CGFloat = 20
    }

    let windowUUID: WindowUUID
    var currentWindowUUID: UUID? { windowUUID }

    // Adjusting layout for devices with height lower than 667
    // including now iPhone SE 2nd generation and iPad
    var shouldUseSmallDeviceLayout: Bool {
        return view.frame.height <= 667 || UIDevice.current.userInterfaceIdiom == .pad
    }

    // Adjusting layout for tiny devices (iPhone SE 1st generation)
    var shouldUseTinyDeviceLayout: Bool {
        return UIDevice().isTinyFormFactor
    }

    // MARK: - Common UI Elements
    lazy var scrollView: UIScrollView = .build { view in
        view.backgroundColor = .clear
    }

    lazy var containerView: UIView = .build { view in
        view.backgroundColor = .clear
    }

    lazy var contentContainerView: UIView = .build { stack in
        stack.backgroundColor = .clear
    }

    lazy var topStackView: UIStackView = .build { stack in
        stack.backgroundColor = .clear
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = SharedUX.topStackViewSpacing
        stack.axis = .vertical
    }

    lazy var contentStackView: UIStackView = .build { stack in
        stack.backgroundColor = .clear
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.axis = .vertical
    }
    lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "\(self.viewModel.a11yIdRoot)ImageView"
    }

    lazy var titleLabel: UILabel = .build { label in
        label.numberOfLines = 0
        label.textAlignment = .center
        let fontSize = self.shouldUseSmallDeviceLayout ? SharedUX.smallTitleFontSize : SharedUX.titleFontSize
        label.font = DefaultDynamicFontHelper.preferredBoldFont(withTextStyle: .largeTitle,
                                                                size: fontSize)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "\(self.viewModel.a11yIdRoot)TitleLabel"
        label.accessibilityTraits.insert(.header)
    }

    lazy var descriptionLabel: UILabel = .build { label in
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .body,
            size: SharedUX.descriptionFontSize
        )
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "\(self.viewModel.a11yIdRoot)DescriptionLabel"
    }

    lazy var primaryButton: PrimaryRoundedButton = .build { button in
        button.addTarget(self, action: #selector(self.primaryAction), for: .touchUpInside)
    }

    lazy var secondaryButton: SecondaryRoundedButton = .build { button in
        button.addTarget(self, action: #selector(self.secondaryAction), for: .touchUpInside)
    }

    // MARK: - Themeable
    var themeManager: Common.ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: Common.NotificationProtocol

    var viewModel: OnboardingCardInfoModelProtocol

    // MARK: - Initializers
    init(
        viewModel: OnboardingCardInfoModelProtocol,
        themeManager: ThemeManager = AppContainer.shared.resolve(),
        notificationCenter: NotificationProtocol = NotificationCenter.default
    ) {
        self.viewModel = viewModel
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLayout() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.body
        imageView.image = viewModel.image

        setupPrimaryButton()
        setupSecondaryButton()
    }

    @objc
    func primaryAction() { }

    @objc
    func secondaryAction() { }

    func setupPrimaryButton() {
        let buttonViewModel = PrimaryRoundedButtonViewModel(
            title: viewModel.buttons.primary.title,
            a11yIdentifier: "\(self.viewModel.a11yIdRoot)PrimaryButton"
        )

        primaryButton.configure(viewModel: buttonViewModel)
        primaryButton.applyTheme(theme: themeManager.currentTheme)
    }

    func setupSecondaryButton() {
        let buttonViewModel = SecondaryRoundedButtonViewModel(
            title: viewModel.buttons.secondary?.title,
            a11yIdentifier: "\(self.viewModel.a11yIdRoot)SecondaryButton"
        )

        secondaryButton.configure(viewModel: buttonViewModel)
        secondaryButton.applyTheme(theme: themeManager.currentTheme)
    }

    func applyTheme() { }
}
