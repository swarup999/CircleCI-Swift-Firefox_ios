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

    let imageView = UIView()
    let messageLabel = UILabel()
    let reloadButton = UIButton(type: .system)

    override func viewDidLoad() {
           super.viewDidLoad()

           // Set background color
           view.backgroundColor = .white

           // Image View Configuration
           imageView.backgroundColor = .systemBlue
           imageView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(imageView)

           // Message Label Configuration
           messageLabel.text = "Looks like there’s a problem with your internet connection.\n\nTry connecting on a different device. Check your modem or router. Disconnect and reconnect to Wi-Fi."
           messageLabel.numberOfLines = 0
           messageLabel.textAlignment = .center
           messageLabel.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(messageLabel)

           // Reload Button Configuration
           reloadButton.setTitle("Reload", for: .normal)
           reloadButton.backgroundColor = .systemBlue
           reloadButton.setTitleColor(.white, for: .normal)
           reloadButton.layer.cornerRadius = 5
           reloadButton.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(reloadButton)

           // Constraints
           setupConstraints()
       }

       override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
           super.viewWillTransition(to: size, with: coordinator)
           setupConstraints()
       }

       func setupConstraints() {
           let isPortrait = UIDevice.current.orientation.isPortrait

           // Remove existing constraints
           view.removeConstraints(view.constraints)

           // Common Constraints
           NSLayoutConstraint.activate([
               imageView.widthAnchor.constraint(equalToConstant: 100),
               imageView.heightAnchor.constraint(equalToConstant: 100),
               reloadButton.heightAnchor.constraint(equalToConstant: 50),
               reloadButton.widthAnchor.constraint(equalToConstant: 200)
           ])

           if isPortrait {
               // Portrait Constraints
               NSLayoutConstraint.activate([
                   imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
                   messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                   messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   reloadButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
                   reloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
               ])
           } else {
               // Landscape Constraints
               NSLayoutConstraint.activate([
                   imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                   messageLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
                   messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                   reloadButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
                   reloadButton.centerXAnchor.constraint(equalTo: messageLabel.centerXAnchor)
               ])
           }
       }
   }
