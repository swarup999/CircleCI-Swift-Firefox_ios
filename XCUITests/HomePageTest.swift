/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class HomePageTest: BaseTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetInternalURLAsHomepage() {
        let app = XCUIApplication()
        
        loadWebPage("http://en.m.wikipedia.org/wiki/Main_Page")
        app.buttons["TabLocationView.readerModeButton"].tap()
        app.buttons["TabToolbar.menuButton"].tap()
        app.cells["Set Homepage"].tap()

        XCTAssertFalse(app.alerts["HomePageDialog"].exists)
    }
}
