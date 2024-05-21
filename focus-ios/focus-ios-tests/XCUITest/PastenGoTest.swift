/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class PastenGoTest: BaseTestCase {
    
    func testCopyMenuItem() throws {
        let urlBarTextField = app.textFields["URLBar.urlText"]
        loadWebPage("https://www.example.com")
        waitForWebPageLoad()

        // Must offset textfield press to support 5S.
        urlBarTextField.press(forDuration: 2)
        waitForExistence(app.menuItems["Copy"])
        app.menuItems["Copy"].tap()
        waitForNoExistence(app.menuItems["Copy"])

        loadWebPage("bing.com")
        waitForWebPageLoad()
        urlBarTextField.tap()
        urlBarTextField.press(forDuration: 2)
        waitForExistence(app.collectionViews.menuItems.firstMatch)
        waitForHittable(app.buttons["Forward"].firstMatch)
        app.buttons["Forward"].firstMatch.tap()
        if !iPad() {
            waitForExistence(app.collectionViews.menuItems.firstMatch)
            waitForHittable(app.buttons["Forward"].firstMatch)
            app.buttons["Forward"].firstMatch.tap()
        }
        waitForExistence(app.collectionViews.menuItems.firstMatch)
        waitForHittable(app.menuItems["Paste & Go"])
        app.menuItems["Paste & Go"].tap()

        waitForWebPageLoad()
        guard let text = urlBarTextField.value as? String else {
            XCTFail()
            return
        }

        XCTAssert(text == "www.example.com")
    }

    // Test the clipboard contents are displayed/updated properly
    func testClipboard() throws {
        let app = XCUIApplication()

        // Inject a string into clipboard
        let clipboardString = "Hello world"
        UIPasteboard.general.string = clipboardString

        // Enter 'mozilla' on the search field
        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]
        searchOrEnterAddressTextField.typeText("mozilla")

        // Check clipboard suggestion is shown
        waitForValueContains(searchOrEnterAddressTextField, value: "mozilla.org/")
        waitForExistence(app.buttons["Search for mozilla"])
        app.typeText("\n")

        // Check the correct site is reached
        waitForValueContains(searchOrEnterAddressTextField, value: "www.mozilla")
        waitForWebPageLoad()

        // Tap URL field, check for paste & go menu
        if iPad() {
            searchOrEnterAddressTextField.tap()
            sleep(1)
        }
        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.press(forDuration: 1.5)

        // Copy URL into clipboard
        waitForHittable(app.buttons["Forward"].firstMatch)
        XCTAssertTrue(app.menuItems["Copy"].isEnabled)
        app.menuItems["Copy"].tap()

        // Clear and start typing on the URL field again, verify the clipboard suggestion changes
        // If it's a URL, do not prefix "Search For"
        // Note: I can't click through "XCUITest-Runner would like to paste from Firefox Focus"
        // system dialog.
        app.buttons["icon clear"].tap()
        // searchOrEnterAddressTextField.typeText("mozilla")
        // waitForExistence(app.buttons["Search for mozilla"])
        // XCTAssertTrue(app.buttons[UIPasteboard.general.string!].isEnabled)
    }

    // Smoketest
    // Test Paste & Go feature
    func testPastenGo() {
        // Inject a string into clipboard
        var clipboard = "https://www.mozilla.org/en-US/"
        UIPasteboard.general.string = clipboard

        // Tap url bar to show context menu
        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]
        waitForExistence(searchOrEnterAddressTextField, timeout: 30)
        searchOrEnterAddressTextField.tap()
        waitForExistence(app.menuItems["Paste"], timeout: 10)
        XCTAssertTrue(app.menuItems["Paste & Go"].isEnabled)

        // Note: I can't click through "XCUITest-Runner would like to paste from Firefox Focus"
        // system dialog.
        /*

        // Select paste and go, and verify it goes to the correct place
        app.menuItems["Paste & Go"].tap()

        waitForExistence(app.textFields["URLBar.urlText"], timeout: 10)
        waitForWebPageLoad()
        // Check the correct site is reached
        waitForValueContains(searchOrEnterAddressTextField, value: "mozilla.org")
        app.buttons["URLBar.deleteButton"].firstMatch.tap()
        waitForExistence(app.staticTexts["Browsing history cleared"])

        clipboard = "1(*&)(*%@@$^%^12345)"
        UIPasteboard.general.string = clipboard
        waitForExistence(searchOrEnterAddressTextField, timeout: 3)
        searchOrEnterAddressTextField.tap()
        waitForExistence(app.menuItems["Paste"], timeout: 5)
        app.menuItems["Paste"].tap()
        waitForValueContains(app.textFields["URLBar.urlText"], value: "1(*&)(*%@@$^%^12345)")
        */
    }
}
