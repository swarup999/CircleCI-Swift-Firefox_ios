// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common

class ThemeSetting: Setting {
    private weak var settingsDelegate: GeneralSettingsDelegate?
    private let profile: Profile
    private let themeManager: ThemeManager

    override var accessoryView: UIImageView? {
        return SettingDisclosureUtility.buildDisclosureIndicator(theme: theme)
    }
    override var style: UITableViewCell.CellStyle { return .value1 }

    override var accessibilityIdentifier: String? {
        return AccessibilityIdentifiers.Settings.Theme.title
    }

    override var status: NSAttributedString {
        if themeManager.systemThemeIsOn {
            return NSAttributedString(string: .SystemThemeSectionHeader)
        } else if !themeManager.automaticBrightnessIsOn {
            return NSAttributedString(string: .DisplayThemeManualStatusLabel)
        } else if themeManager.automaticBrightnessIsOn {
            return NSAttributedString(string: .DisplayThemeAutomaticStatusLabel)
        }

        return NSAttributedString(string: "")
    }

    init(settings: SettingsTableViewController,
         settingsDelegate: GeneralSettingsDelegate?,
         themeManager: ThemeManager = AppContainer.shared.resolve()
    ) {
        self.profile = settings.profile
        self.settingsDelegate = settingsDelegate
<<<<<<< HEAD:Client/Frontend/Settings/Main/General/ThemeSetting.swift
        super.init(title: NSAttributedString(string: .SettingsDisplayThemeTitle,
                                             attributes: [NSAttributedString.Key.foregroundColor: settings.themeManager.currentTheme.colors.textPrimary]))
=======
        self.themeManager = themeManager

        super.init(
            title: NSAttributedString(
                string: .SettingsDisplayThemeTitle,
                attributes: [
                    NSAttributedString.Key.foregroundColor: settings.themeManager.currentTheme.colors.textPrimary
                ]
            )
        )
>>>>>>> 43e00b79f (Bugfix FXIOS-8309 [v122.1] System theme resetting bug (#18429)):firefox-ios/Client/Frontend/Settings/Main/General/ThemeSetting.swift
    }

    override func onClick(_ navigationController: UINavigationController?) {
        settingsDelegate?.pressedTheme()
    }
}
