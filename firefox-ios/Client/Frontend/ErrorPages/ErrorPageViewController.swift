// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import UIKit
import Shared

class ErrorPageViewController:
    UIViewController,
    ContentContainable,
    Themeable,
    FeatureFlaggable {
    // MARK: ContentContainable Variables
    var contentType: ContentType = .privateHomepage

    // MARK: Theming Variables
    var themeManager: Common.ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: Common.NotificationProtocol
    let windowUUID: WindowUUID
    var currentWindowUUID: UUID? { windowUUID }

    private let overlayManager: OverlayModeManager
    private let logger: Logger

    func applyTheme() {
        //
    }

    init(windowUUID: WindowUUID,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default,
         logger: Logger = DefaultLogger.shared,
         overlayManager: OverlayModeManager
    ) {
        self.windowUUID = windowUUID
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        self.logger = logger
        self.overlayManager = overlayManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Background color
        view.backgroundColor = .white

        // Cute Logo Image
        let logoImageView = UIView()
        logoImageView.backgroundColor = .blue
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        // Error message
        let errorMessageLabel = UILabel()
        errorMessageLabel.text = "Looks like there's a problem with your internet connection."
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorMessageLabel)

        // Instruction message
        let instructionLabel = UILabel()
        instructionLabel.text = "Try connecting on a different device. Check your modem or router. Disconnect and reconnect to Wi-Fi."
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        // Reload button
        let reloadButton = UIButton(type: .system)
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.backgroundColor = .blue
        reloadButton.setTitleColor(.white, for: .normal)
        reloadButton.layer.cornerRadius = 10
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reloadButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Logo Image
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            // Error Message
            errorMessageLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Instruction Message
            instructionLabel.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Reload Button
            reloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            reloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc
    func reloadButtonTapped() {
        // Reload action
        print("Reload button tapped")
    }
}
