// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import UIKit

class HomeLogoHeaderCell: UICollectionViewCell, ReusableCell {
    private struct UX {
        struct Logo {
            static let imageSize: CGFloat = 40
            static let topConstant: CGFloat = 32
            static let bottomConstant: CGFloat = -10
        }

        struct TextImage {
            static let imageWidth: CGFloat = 165.5
            static let imageHeight: CGFloat = 17.5
            static let leadingConstant: CGFloat = 9
            static let trailingConstant: CGFloat = -15
        }
    }

    typealias a11y = AccessibilityIdentifiers.FirefoxHomepage.OtherButtons

    // MARK: - UI Elements
    lazy var logoImage: UIImageView = .build { imageView in
        imageView.image = UIImage(imageLiteralResourceName: ImageIdentifiers.homeHeaderLogoBall)
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = a11y.logoImage
    }

    lazy var logoTextImage: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = a11y.logoText
    }

    // MARK: - Variables
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    private var userDefaults: UserDefaults = UserDefaults.standard

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        applyTheme()
        setupNotifications(forObserver: self,
                           observing: [.DisplayThemeChanged,
                                       .WallpaperDidChange])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    // MARK: - UI Setup
    func setupView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(logoImage)
        contentView.addSubview(logoTextImage)

        NSLayoutConstraint.activate([
            logoImage.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: UX.Logo.topConstant),
            logoImage.widthAnchor.constraint(equalToConstant: UX.Logo.imageSize),
            logoImage.heightAnchor.constraint(equalToConstant: UX.Logo.imageSize),
            logoImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            logoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: UX.Logo.bottomConstant),

            logoTextImage.widthAnchor.constraint(equalToConstant: UX.TextImage.imageWidth),
            logoTextImage.heightAnchor.constraint(equalToConstant: UX.TextImage.imageHeight),
            logoTextImage.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor,
                                                   constant: UX.TextImage.leadingConstant),
            logoTextImage.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                    constant: UX.TextImage.trailingConstant),
            logoTextImage.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor)
        ])
    }
}

// MARK: - Theme
extension HomeLogoHeaderCell: NotificationThemeable {
    func applyTheme() {
        let wallpaperManager = WallpaperManager()
        if let logoTextColor = wallpaperManager.currentWallpaper.logoTextColor {
            logoTextImage.image = UIImage(imageLiteralResourceName: ImageIdentifiers.homeHeaderLogoText)
                .withRenderingMode(.alwaysTemplate)
            logoTextImage.tintColor = logoTextColor
        } else {
            logoTextImage.image = UIImage(imageLiteralResourceName: ImageIdentifiers.homeHeaderLogoText)
                .withRenderingMode(.alwaysTemplate)
            // TODO: Laurie - textPrimary
            logoTextImage.tintColor = LegacyThemeManager.instance.current.homePanel.topSiteHeaderTitle
        }
    }
}

// MARK: - Notifiable
extension HomeLogoHeaderCell: Notifiable {
    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .DisplayThemeChanged,
                .WallpaperDidChange:
            ensureMainThread {
                self.applyTheme()
            }
        default: break
        }
    }
}
