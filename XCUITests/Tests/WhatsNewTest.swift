/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class WhatsNewTest: BaseTestCase {
    func testWhatsNew() {
        navigator.goto(BrowserTabMenu)
        navigator.performAction(Action.OpenWhatsNewPage)
        Base.helper.waitUntilPageLoad()
        Base.helper.waitForValueContains(Base.app.textFields["url"], value: "support")
    }
}
