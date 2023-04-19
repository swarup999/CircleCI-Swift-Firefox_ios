// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

class NimbusOnboardingFeatureLayer {
    // MARK: - Properties
    private let nimbus: FxNimbus

    init(nimbus: FxNimbus = FxNimbus.shared) {
        self.nimbus = nimbus
    }
}

struct OnboardingButtonInfo {
    let title: String
    let action: OnboardingActions
}

struct OnboardingLinkInfo {
    let title: String
    let url: URL
}

struct OnboardingCardInfo {
    let name: String
    let title: String
    let body: String
    let link: OnboardingLink?
    let buttons: [OnboardingButton]
    let type: OnboardingType
}
