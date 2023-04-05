// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import UIKit

public enum AppName: String, CustomStringConvertible {
    case shortName = "Firefox"

    public var description: String {
        return self.rawValue
    }
}

public enum KVOConstants: String {
    case loading = "loading"
    case estimatedProgress = "estimatedProgress"
    case URL = "URL"
    case title = "title"
    case canGoBack = "canGoBack"
    case canGoForward = "canGoForward"
    case contentSize = "contentSize"
}

public struct KeychainKey {
    public static let fxaPushRegistration = "account.push-registration"
    public static let apnsToken = "apnsToken"
}

public class AppConstants {
    // Any type of tests (UI and Unit)
    public static let isRunningTest = NSClassFromString("XCTestCase") != nil
    || AppConstants.isRunningUITests
    || AppConstants.isRunningPerfTests

    // Unit tests only
    public static let isRunningUnitTest = NSClassFromString("XCTestCase") != nil
    && !AppConstants.isRunningUITests
    && !AppConstants.isRunningPerfTests

    // Only UI tests
    public static let isRunningUITests = ProcessInfo.processInfo.arguments.contains(LaunchArguments.Test)

    // Only performance tests
    public static let isRunningPerfTests = ProcessInfo.processInfo.arguments.contains(LaunchArguments.PerformanceTest)

    public static let scheme: String = {
        guard let identifier = Bundle.main.bundleIdentifier else {
            return "unknown"
        }

        let scheme = identifier.replacingOccurrences(of: "org.mozilla.ios.", with: "")
        if scheme == "FirefoxNightly.enterprise" {
            return "FirefoxNightly"
        }
        return scheme
    }()

    public static let prefSendUsageData = "settings.sendUsageData"
    public static let prefStudiesToggle = "settings.studiesToggle"

    /// Build Channel.
    public static let buildChannel: AppBuildChannel = {
        #if MOZ_CHANNEL_RELEASE
        return AppBuildChannel.release
        #elseif MOZ_CHANNEL_BETA
        return AppBuildChannel.beta
        #elseif MOZ_CHANNEL_FENNEC
        return AppBuildChannel.developer
        #else
        return AppBuildChannel.other
        #endif
    }()

    /// Enables support for International Domain Names (IDN)
    /// Disabled because of https://bugzilla.mozilla.org/show_bug.cgi?id=1312294
    public static let punyCode: Bool = {
        #if MOZ_CHANNEL_RELEASE
            return false
        #elseif MOZ_CHANNEL_BETA
            return false
        #elseif MOZ_CHANNEL_FENNEC
            return true
        #else
            return true
        #endif
    }()

    /// The maximum length of a URL stored by Firefox. Shared with Places on desktop.
    public static let databaseURLLengthMax = 65536

    /// Time that needs to pass before polling FxA for send tabs again, 86_400_000 milliseconds is 1 day
    public static let fxaCommandsInterval = 86_400_000

    /// The maximum number of times we should attempt to migrated the History to Application Services Places DB
    public static let maxHistoryMigrationAttempt = 5

    /// The maximum size of the places DB in bytes
    public static let databaseSizeLimitInBytes: UInt32 = 75 * 1024 * 1024 // corresponds to 75MiB (in bytes)

    /// Fixed short version for nightly builds
    public static let nightlyAppVersion = "9000"

    /// A hard coded flag until development on the coordinator is done
    public static let useCoordinators = true
}
