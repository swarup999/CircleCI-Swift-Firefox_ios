// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

/// Utility functions related to Fakespot
public struct FakespotUtils: FeatureFlaggable {
    public static var learnMoreUrl: URL? {
        // Returns the predefined URL associated to learn more button action.
        guard let url = SupportUtils.URLForTopic("review_checker_mobile") else { return nil }

        let queryItems = [URLQueryItem(name: "utm_campaign", value: "fakespot-by-mozilla"),
                          URLQueryItem(name: "utm_term", value: "core-sheet")]
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        return urlComponents?.url
    }

    public static var privacyPolicyUrl: URL? {
        // Returns the predefined URL associated to privacy policy button action.
        return URL(string: "https://www.fakespot.com/privacy-policy")
    }

    public static var termsOfUseUrl: URL? {
        // Returns the predefined URL associated to terms of use button action.
        return URL(string: "https://www.fakespot.com/terms")
    }

    public static var fakespotUrl: URL? {
        // Returns the predefined URL associated to Fakespot button action.
        return URL(string: "https://www.fakespot.com/our-mission?utm_source=review-checker&utm_campaign=fakespot-by-mozilla&utm_medium=inproduct&utm_term=core-sheet")
    }

    func addSettingTelemetry(profile: Profile = AppContainer.shared.resolve()) {
        let isFeatureEnabled = featureFlags.isFeatureEnabled(.fakespotFeature, checking: .buildOnly)
        TelemetryWrapper.recordEvent(
            category: .information,
            method: .settings,
            object: .shoppingNimbusDisabled,
            extras: [
                TelemetryWrapper.ExtraKey.Shopping.isNimbusDisabled.rawValue: !isFeatureEnabled
            ]
        )

        let isOptedOut = profile.prefs.boolForKey(PrefsKeys.Shopping2023ExplicitOptOut) ?? false
        TelemetryWrapper.recordEvent(
            category: .information,
            method: .settings,
            object: .shoppingComponentOptedOut,
            extras: [
                TelemetryWrapper.ExtraKey.Shopping.isComponentOptedOut.rawValue: isOptedOut
            ]
        )

        let isUserOnboarded = profile.prefs.boolForKey(PrefsKeys.Shopping2023OptInSeen) ?? false
        TelemetryWrapper.recordEvent(
            category: .information,
            method: .settings,
            object: .shoppingUserHasOnboarded,
            extras: [
                TelemetryWrapper.ExtraKey.Shopping.isUserOnboarded.rawValue: isUserOnboarded
            ]
        )
    }

    func isPadInMultitasking(device: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom,
                             window: UIWindow? = UIWindow.keyWindow) -> Bool {
        guard device == .pad, let window else { return false }

        return window.frame.width != window.screen.bounds.width || window.frame.height != window.screen.bounds.height
    }

    func shouldDisplayInSidebar() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad && !isPadInMultitasking()
    }
}
