// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Redux

enum FakespotAction: Action {
    case settingsStateDidChange
    case reviewQualityDidChange
    case tabDidChange(tabUIDD: String)
    case pressedShoppingButton
    case show
    case dismiss
    case setAppearanceTo(Bool)
    case adsImpressionEventSendFor(String)
    case adsExposureEventSendFor(String)
    case sheetDisplayedEventSend
}
