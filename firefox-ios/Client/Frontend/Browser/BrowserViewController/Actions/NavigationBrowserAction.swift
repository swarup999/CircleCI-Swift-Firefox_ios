// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Redux
/// Holds the various navigation that
class NavigationBrowserAction: Action {
    let urlToVisit: URL?
    init(urlToVisit: URL? = nil,
         windowUUID: WindowUUID,
         actionType: ActionType) {
        self.urlToVisit = urlToVisit
        super.init(windowUUID: windowUUID,
                   actionType: actionType)
    }
}

enum NavigationBrowserActionType: ActionType {
    case tapOnCustomizeHomepage
    case tapOnCell
    case tapOnLink
}
