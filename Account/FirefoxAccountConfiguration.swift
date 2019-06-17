/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

public enum FirefoxAccountConfigurationLabel: String {
    case latestDev = "LatestDev"
    case stableDev = "StableDev"
    case stage = "Stage"
    case production = "Production"
    case chinaEdition = "ChinaEdition"
    case custom = "Custom"

    public func toConfiguration(prefs: Prefs? = nil) -> FirefoxAccountConfiguration {
        switch self {
        case .latestDev: return LatestDevFirefoxAccountConfiguration(prefs: prefs)
        case .stableDev: return StableDevFirefoxAccountConfiguration(prefs: prefs)
        case .stage: return StageFirefoxAccountConfiguration(prefs: prefs)
        case .production: return ProductionFirefoxAccountConfiguration(prefs: prefs)
        case .chinaEdition: return ChinaEditionFirefoxAccountConfiguration(prefs: prefs)
        case .custom: return CustomFirefoxAccountConfiguration(prefs: prefs)
        }
    }
}

/**
 * In the URLs below, service=sync ensures that we always get the keys with signin messages,
 * and context=fx_ios_v1 opts us in to the Desktop Sync postMessage interface.
 */
public protocol FirefoxAccountConfiguration {
    var label: FirefoxAccountConfigurationLabel { get }

    /// A Firefox Account exists on a particular server.  The auth endpoint should speak the protocol documented at
    /// https://github.com/mozilla/fxa-auth-server/blob/02f88502700b0c5ef5a4768a8adf332f062ad9bf/docs/api.md
    var authEndpointURL: URL { get }

    /// The associated oauth server should speak the protocol documented at
    /// https://github.com/mozilla/fxa-oauth-server/blob/6cc91e285fc51045a365dbacb3617ef29093dbc3/docs/api.md
    var oauthEndpointURL: URL { get }

    var profileEndpointURL: URL { get }

    /// The associated content server should speak the protocol implemented (but not yet documented) at
    /// https://github.com/mozilla/fxa-content-server/blob/161bff2d2b50bac86ec46c507e597441c8575189/app/scripts/models/auth_brokers/fx-desktop.js
    var signInURL: URL { get }
    var settingsURL: URL { get }
    var forceAuthURL: URL { get }

    var sync15Configuration: Sync15Configuration { get }

    var pushConfiguration: PushConfiguration { get }

    var prefs: Prefs? { get }

    init(prefs: Prefs?)
}

public struct LatestDevFirefoxAccountConfiguration: FirefoxAccountConfiguration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public let label = FirefoxAccountConfigurationLabel.latestDev

    public let authEndpointURL = URL(string: "https://latest.dev.lcip.org/auth/v1")!
    public let oauthEndpointURL = URL(string: "https://oauth-latest.dev.lcip.org")!
    public let profileEndpointURL = URL(string: "https://latest.dev.lcip.org/profile")!

    public let signInURL = URL(string: "https://latest.dev.lcip.org/signin?service=sync&context=fx_ios_v1")!
    public let settingsURL = URL(string: "https://latest.dev.lcip.org/settings?context=fx_ios_v1")!
    public let forceAuthURL = URL(string: "https://latest.dev.lcip.org/force_auth?service=sync&context=fx_ios_v1")!

    public var sync15Configuration: Sync15Configuration {
        get {
            return StageSync15Configuration(prefs: self.prefs)
        }
    }

    public let pushConfiguration: PushConfiguration = FennecPushConfiguration()
}

public struct StableDevFirefoxAccountConfiguration: FirefoxAccountConfiguration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public let label = FirefoxAccountConfigurationLabel.stableDev

    public let authEndpointURL = URL(string: "https://stable.dev.lcip.org/auth/v1")!
    public let oauthEndpointURL = URL(string: "https://oauth-stable.dev.lcip.org")!
    public let profileEndpointURL = URL(string: "https://stable.dev.lcip.org/profile")!

    public let signInURL = URL(string: "https://stable.dev.lcip.org/signin?service=sync&context=fx_ios_v1")!
    public let settingsURL = URL(string: "https://stable.dev.lcip.org/settings?context=fx_ios_v1")!
    public let forceAuthURL = URL(string: "https://stable.dev.lcip.org/force_auth?service=sync&context=fx_ios_v1")!

    public var sync15Configuration: Sync15Configuration {
        get {
            return StageSync15Configuration(prefs: self.prefs)
        }
    }

    public let pushConfiguration: PushConfiguration = FennecPushConfiguration()
}

public struct StageFirefoxAccountConfiguration: FirefoxAccountConfiguration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public let label = FirefoxAccountConfigurationLabel.stage

    public let authEndpointURL = URL(string: "https://api-accounts.stage.mozaws.net/v1")!
    public let oauthEndpointURL = URL(string: "https://oauth.stage.mozaws.net/v1")!
    public let profileEndpointURL = URL(string: "https://profile.stage.mozaws.net/v1")!

    public let signInURL = URL(string: "https://accounts.stage.mozaws.net/signin?service=sync&context=fx_ios_v1")!
    public let settingsURL = URL(string: "https://accounts.stage.mozaws.net/settings?context=fx_ios_v1")!
    public let forceAuthURL = URL(string: "https://accounts.stage.mozaws.net/force_auth?service=sync&context=fx_ios_v1")!

    public var sync15Configuration: Sync15Configuration {
        get {
            return StageSync15Configuration(prefs: self.prefs)
        }
    }

    public var pushConfiguration: PushConfiguration {
        get {
            #if MOZ_CHANNEL_RELEASE
                return FirefoxStagingPushConfiguration()
            #elseif MOZ_CHANNEL_BETA
                return FirefoxBetaStagingPushConfiguration()
            #elseif MOZ_CHANNEL_FENNEC
                return FennecStagingPushConfiguration()
            #endif
        }
    }
}

public struct ProductionFirefoxAccountConfiguration: FirefoxAccountConfiguration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public let label = FirefoxAccountConfigurationLabel.production

    // From https://accounts.firefox.com/.well-known/fxa-client-configuration
    public let authEndpointURL = URL(string: "https://api.accounts.firefox.com/v1")!
    public let oauthEndpointURL = URL(string: "https://oauth.accounts.firefox.com/v1")!
    public let profileEndpointURL = URL(string: "https://profile.accounts.firefox.com/v1")!

    public let signInURL = URL(string: "https://accounts.firefox.com/signin?service=sync&context=fx_ios_v1")!
    public let settingsURL = URL(string: "https://accounts.firefox.com/settings?context=fx_ios_v1")!
    public let forceAuthURL = URL(string: "https://accounts.firefox.com/force_auth?service=sync&context=fx_ios_v1")!

    public var sync15Configuration: Sync15Configuration {
        get {
            return ProductionSync15Configuration(prefs: self.prefs)
        }
    }

    public let pushConfiguration: PushConfiguration = FirefoxPushConfiguration()
}

public struct CustomFirefoxAccountConfiguration: FirefoxAccountConfiguration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public let label = FirefoxAccountConfigurationLabel.custom

    public var authEndpointURL: URL {
        get {
            if let authServer = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncAuth), let url = URL(string: authServer + "/v1") {
                return url
            }

            // If somehow an invalid url was stored, fallback to the production URL
            return ProductionFirefoxAccountConfiguration().authEndpointURL
        }
    }

    public var oauthEndpointURL: URL {
        get {
            if let oauthServer = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncOauth), let url = URL(string: oauthServer + "/v1") {
                return url
            }
            return ProductionFirefoxAccountConfiguration().oauthEndpointURL
        }
    }

    public var profileEndpointURL: URL {
        get {
            if let profileServer = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncProfile), let url = URL(string: profileServer + "/v1") {
                return url
            }
            return ProductionFirefoxAccountConfiguration().profileEndpointURL
        }
    }

    public var signInURL: URL {
        get {
            if let signIn = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncWeb), let url = URL(string: signIn + "/signin?service=sync&context=fx_ios_v1") {
                return url
            }
            return ProductionFirefoxAccountConfiguration().signInURL
        }
    }

    public var forceAuthURL: URL {
        get {
            if let forceAuth = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncWeb), let url = URL(string: forceAuth + "/force_auth?service=sync&context=fx_ios_v1") {
                return url
            }
            return ProductionFirefoxAccountConfiguration().forceAuthURL
        }
    }

    public var settingsURL: URL {
        get {
            if let settings = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncWeb), let url = URL(string: settings + "/settings?service=sync&context=fx_ios_v1") {
                return url
            }
            return ProductionFirefoxAccountConfiguration().settingsURL
        }
    }

    public var sync15Configuration: Sync15Configuration {
        get {
            return CustomSync15Configuration(prefs: self.prefs)
        }
    }

    public let pushConfiguration: PushConfiguration = FirefoxPushConfiguration()
}

public struct ChinaEditionFirefoxAccountConfiguration: FirefoxAccountConfiguration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public let label = FirefoxAccountConfigurationLabel.chinaEdition

    public let authEndpointURL = URL(string: "https://api-accounts.firefox.com.cn/v1")!
    public let oauthEndpointURL = URL(string: "https://oauth.firefox.com.cn/v1")!
    public let profileEndpointURL = URL(string: "https://profile.firefox.com.cn/v1")!

    public let signInURL = URL(string: "https://accounts.firefox.com.cn/signin?service=sync&context=fx_ios_v1")!
    public let settingsURL = URL(string: "https://accounts.firefox.com.cn/settings?context=fx_ios_v1")!
    public let forceAuthURL = URL(string: "https://accounts.firefox.com.cn/force_auth?service=sync&context=fx_ios_v1")!

    public var sync15Configuration: Sync15Configuration {
        get {
            return ChinaEditionSync15Configuration(prefs: self.prefs)
        }
    }

    public let pushConfiguration: PushConfiguration = FirefoxPushConfiguration()
}

public protocol Sync15Configuration {
    var tokenServerEndpointURL: URL { get }
}

// If the user specifies a custom Sync token server URI in the "Advanced Sync Settings"
// menu (toggled via enabling the Debug menu), this will return a URL to override
// whatever Sync token server they would otherwise get by default. They can also provide
// an autoconfig URI that gives a full set of URLs to use for FxA/Sync and still also
// provide a custom Sync token server URI to override that value with.
fileprivate func overriddenCustomSyncTokenServerURI(prefs: Prefs?) -> URL? {
    guard let prefs = prefs, prefs.boolForKey(PrefsKeys.KeyUseCustomSyncTokenServerOverride) ?? false, let customSyncTokenServerURIString = prefs.stringForKey(PrefsKeys.KeyCustomSyncTokenServerOverride) else {
        return nil
    }

    return URL(string: customSyncTokenServerURIString)
}

public struct ChinaEditionSync15Configuration: Sync15Configuration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public var tokenServerEndpointURL: URL {
        return overriddenCustomSyncTokenServerURI(prefs: prefs) ??
            URL(string: "https://sync.firefox.com.cn/token/1.0/sync/1.5")!
    }
}

public struct ProductionSync15Configuration: Sync15Configuration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public var tokenServerEndpointURL: URL {
        return overriddenCustomSyncTokenServerURI(prefs: prefs) ??
            URL(string: "https://token.services.mozilla.com/1.0/sync/1.5")!
    }
}

public struct StageSync15Configuration: Sync15Configuration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public var tokenServerEndpointURL: URL {
        return overriddenCustomSyncTokenServerURI(prefs: prefs) ??
            URL(string: "https://token.stage.mozaws.net/1.0/sync/1.5")!
    }
}

public struct CustomSync15Configuration: Sync15Configuration {
    public init(prefs: Prefs? = nil) {
        self.prefs = prefs
    }

    public var prefs: Prefs?

    public var tokenServerEndpointURL: URL {
        if let tokenServer = self.prefs?.stringForKey(PrefsKeys.KeyCustomSyncToken), let url = URL(string: tokenServer + "/1.0/sync/1.5") {
            return overriddenCustomSyncTokenServerURI(prefs: prefs) ?? url
        }

        return overriddenCustomSyncTokenServerURI(prefs: prefs) ??
            ProductionSync15Configuration().tokenServerEndpointURL
    }
}
