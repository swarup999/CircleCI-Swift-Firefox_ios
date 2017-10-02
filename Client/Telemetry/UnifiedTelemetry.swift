/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Telemetry

//
// 'Unified Telemetry' is the name for Mozilla's telemetry system
//
class UnifiedTelemetry {
    init(profile: Profile) {
        NotificationCenter.default.addObserver(self, selector: #selector(uploadError(notification:)), name: Telemetry.notificationUploadError, object: nil)

        let telemetryConfig = Telemetry.default.configuration
        telemetryConfig.appName = AppInfo.displayName
        telemetryConfig.userDefaultsSuiteName = AppInfo.sharedContainerIdentifier
        telemetryConfig.dataDirectory = .documentDirectory

        #if DEBUG
            telemetryConfig.updateChannel = "debug"
            telemetryConfig.isCollectionEnabled = false
            telemetryConfig.isUploadEnabled = false
        #else
            telemetryConfig.updateChannel = "release"
            let sendUsageData = profile.prefs.boolForKey(AppConstants.PrefSendUsageData) ?? true
            telemetryConfig.isCollectionEnabled = sendUsageData
            telemetryConfig.isUploadEnabled = sendUsageData
        #endif

        Telemetry.default.add(pingBuilderType: CorePingBuilder.self)
    }

    @objc func uploadError(notification: NSNotification) {
        guard let error = notification.userInfo?["error"] as? NSError else { return }
        SentryIntegration.shared.send(message: error.localizedDescription, tag: "UnifiedTelemetry", severity: .info)
    }
}

