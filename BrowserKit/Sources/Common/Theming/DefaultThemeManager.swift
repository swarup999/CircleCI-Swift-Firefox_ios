// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

/// The `ThemeManager` will be responsible for providing the theme throughout the app
public final class DefaultThemeManager: ThemeManager, Notifiable {
    // These have been carried over from the legacy system to maintain backwards compatibility
    private enum ThemeKeys {
        static let themeName = "prefKeyThemeName"
        static let systemThemeIsOn = "prefKeySystemThemeSwitchOnOff"

        enum AutomaticBrightness {
            static let isOn = "prefKeyAutomaticSwitchOnOff"
            static let thresholdValue = "prefKeyAutomaticSliderValue"
        }

        enum NightMode {
            static let isOn = "profile.NightModeStatus"
        }

        enum PrivateMode {
            static let isOn = "profile.PrivateModeStatus"
        }
    }

    // MARK: - Variables

    public var currentTheme: Theme = LightTheme()
    public var notificationCenter: NotificationProtocol
    private var userDefaults: UserDefaultsInterface
    private var mainQueue: DispatchQueueInterface
    private var sharedContainerIdentifier: String

    public var window: UIWindow?

    // MARK: - Init

    private var privateModeIsOn: Bool {
        return userDefaults.bool(forKey: ThemeKeys.PrivateMode.isOn)
    }

    public var systemThemeIsOn: Bool {
        return userDefaults.bool(forKey: ThemeKeys.systemThemeIsOn)
    }

    public var automaticBrightnessIsOn: Bool {
        return userDefaults.bool(forKey: ThemeKeys.AutomaticBrightness.isOn)
    }

    // MARK: - Initializers

    public init(
        userDefaults: UserDefaultsInterface = UserDefaults.standard,
        notificationCenter: NotificationProtocol = NotificationCenter.default,
        mainQueue: DispatchQueueInterface = DispatchQueue.main,
        sharedContainerIdentifier: String
    ) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.mainQueue = mainQueue
        self.sharedContainerIdentifier = sharedContainerIdentifier

        self.userDefaults.register(defaults: [
            ThemeKeys.systemThemeIsOn: true,
            ThemeKeys.NightMode.isOn: NSNumber(value: false),
            ThemeKeys.PrivateMode.isOn: NSNumber(value: false),
        ])

        changeCurrentTheme(loadInitialThemeType())

        setupNotifications(forObserver: self,
                           observing: [UIScreen.brightnessDidChangeNotification,
                                       UIApplication.didBecomeActiveNotification])
    }

    // MARK: - ThemeManager

    public func changeCurrentTheme(_ newTheme: ThemeType) {
        guard currentTheme.type != newTheme else { return }
        currentTheme = newThemeForType(newTheme)

        // overwrite the user interface style on the window attached to our scene
        // once we have multiple scenes we need to update all of them
        window?.overrideUserInterfaceStyle = currentTheme.type.getInterfaceStyle()

        mainQueue.ensureMainThread { [weak self] in
            self?.notificationCenter.post(name: .ThemeDidChange)
        }
    }

    public func systemThemeChanged() {
        // Ignore if:
        // the system theme is off
        // OR night mode is on
        // OR private mode is on
        guard systemThemeIsOn,
              !nightModeIsOn,
              !privateModeIsOn
        else { return }

        changeCurrentTheme(getSystemThemeType())
    }

    public func setSystemTheme(isOn: Bool) {
        userDefaults.set(isOn, forKey: ThemeKeys.systemThemeIsOn)

        if systemThemeIsOn {
            systemThemeChanged()
        } else if automaticBrightnessIsOn {
            updateThemeBasedOnBrightness()
        }
    }

    public func setPrivateTheme(isOn: Bool) {
        userDefaults.set(isOn, forKey: ThemeKeys.PrivateMode.isOn)

        changeCurrentTheme(loadInitialThemeType())
    }

    public func setAutomaticBrightness(isOn: Bool) {
        guard automaticBrightnessIsOn != isOn else { return }

        userDefaults.set(isOn, forKey: ThemeKeys.AutomaticBrightness.isOn)
        brightnessChanged()
    }

    public func setAutomaticBrightnessValue(_ value: Float) {
        userDefaults.set(value, forKey: ThemeKeys.AutomaticBrightness.thresholdValue)
        brightnessChanged()
    }

    // MARK: - Private methods

    private func loadInitialThemeType() -> ThemeType {
        if let privateModeIsOn = userDefaults.object(forKey: ThemeKeys.PrivateMode.isOn) as? NSNumber,
           privateModeIsOn.boolValue == true {
            return .privateMode
        }

        if let nightModeIsOn = userDefaults.object(forKey: ThemeKeys.NightMode.isOn) as? NSNumber,
           nightModeIsOn.boolValue == true {
            return .dark
        }

        var themeType = getSystemThemeType()
        if let savedThemeDescription = userDefaults.string(forKey: ThemeKeys.themeName),
           let savedTheme = ThemeType(rawValue: savedThemeDescription) {
            themeType = savedTheme
        }

        return themeType
    }

    private func getSystemThemeType() -> ThemeType {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? ThemeType.dark : ThemeType.light
    }

    private func newThemeForType(_ type: ThemeType) -> Theme {
        switch type {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        case .privateMode:
            return PrivateModeTheme()
        }
    }

    private func brightnessChanged() {
        if automaticBrightnessIsOn {
            updateThemeBasedOnBrightness()
        } else {
            systemThemeChanged()
        }
    }

    private func updateThemeBasedOnBrightness() {
        let thresholdValue = userDefaults.float(forKey: ThemeKeys.AutomaticBrightness.thresholdValue)
        let currentValue = Float(UIScreen.main.brightness)

        if currentValue < thresholdValue {
            changeCurrentTheme(.dark)
        } else {
            changeCurrentTheme(.light)
        }
    }

    // MARK: - Notifiable

    public func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case UIScreen.brightnessDidChangeNotification:
            brightnessChanged()
        case UIApplication.didBecomeActiveNotification:
            // It seems this notification is fired before the UI is informed of any changes to dark mode
            // So dispatching to the end of the main queue will ensure it's always got the latest info
            DispatchQueue.main.async {
                self.systemThemeChanged()
            }
        default:
            return
        }
    }
}
