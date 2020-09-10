/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import WebKit
import UIKit
import EarlGrey
import GCDWebServers
@testable import Client

class ClearPrivateDataTests: KIFTestCase, UITextFieldDelegate {

    fileprivate var webRoot: String!

    override func setUp() {
        super.setUp()
        webRoot = SimplePageServer.start()
        BrowserUtils.configEarlGrey()
        BrowserUtils.dismissFirstRunUI()
    }

    override func tearDown() {
        BrowserUtils.resetToAboutHome()
    }

    func visitSites(noOfSites: Int) -> [(title: String, domain: String, dispDomain: String, url: String)] {
        var urls: [(title: String, domain: String, dispDomain: String, url: String)] = []
        for pageNo in 1...noOfSites {
            let url = "\(webRoot!)/numberedPage.html?page=\(pageNo)"
            BrowserUtils.enterUrlAddressBar(typeUrl: url)

            tester().waitForAnimationsToFinish()
            tester().waitForWebViewElementWithAccessibilityLabel("Page \(pageNo)")
            let dom = URL(string: url)!.normalizedHost!
            let index = dom.index(dom.startIndex, offsetBy: 7)
            let dispDom = dom.substring(to: index)  // On IPhone, it only displays first 8 chars
            let tuple: (title: String, domain: String, dispDomain: String, url: String)
            = ("Page \(pageNo)", dom, dispDom, url)
            urls.append(tuple)
        }
        BrowserUtils.resetToAboutHome()
        return urls
    }

    func anyDomainsExistOnTopSites(_ domains: Set<String>, fulldomains: Set<String>) {
        if checkDomains(domains: domains) == true {
            return
        } else {
            if checkDomains(domains: fulldomains) == true {
                return
            }
        }
       XCTFail("Couldn't find any domains in top sites.")
    }

    private func checkDomains(domains: Set<String>) -> Bool {
        var errorOrNil: NSError?

        for domain in domains {
            let withoutDot = domain.replacingOccurrences(of: ".", with: " ")
            let matcher = grey_allOf([grey_accessibilityLabel(withoutDot),
                                              grey_kindOfClass(NSClassFromString("Client.TopSiteItemCell")!),
                                              grey_sufficientlyVisible()])
            EarlGrey.selectElement(with: matcher).assert(grey_notNil(), error: &errorOrNil)

            if errorOrNil == nil {
                return true
            }
        }
        return false
    }

    func testRemembersToggles() {
        BrowserUtils.clearPrivateData([BrowserUtils.Clearable.History], swipe:false)
        BrowserUtils.openClearPrivateDataDialog(false)

        // Ensure the toggles match our settings.
        [
            (BrowserUtils.Clearable.Cache, "0"),
            (BrowserUtils.Clearable.Cookies, "0"),
            (BrowserUtils.Clearable.OfflineData, "0"),
            (BrowserUtils.Clearable.History, "1")
        ].forEach { clearable, switchValue in
            XCTAssertNotNil(tester()
                .waitForView(withAccessibilityLabel: clearable.rawValue, value: switchValue, traits: UIAccessibilityTraits.none))
        }
        BrowserUtils.closeClearPrivateDataDialog()
    }

    func testClearsHistoryPanel() {
        let urls = visitSites(noOfSites: 2)

        let url1 = urls[0].url
        let url2 = urls[1].url
        BrowserUtils.openLibraryMenu(tester())
        // Open History Panel
        tester().tapView(withAccessibilityIdentifier: "LibraryPanels.History")
        tester().waitForView(withAccessibilityLabel: url1)
        tester().waitForView(withAccessibilityLabel: url2)

        BrowserUtils.closeLibraryMenu(tester())
        BrowserUtils.clearPrivateData([BrowserUtils.Clearable.History], swipe: false)
        BrowserUtils.openLibraryMenu(tester())
        // Open History Panel
        tester().waitForAbsenceOfView(withAccessibilityLabel: url1)
        tester().waitForAbsenceOfView(withAccessibilityLabel: url2)

        BrowserUtils.closeLibraryMenu(tester())
    }

    func testDisabledHistoryDoesNotClearHistoryPanel() {
        let urls = visitSites(noOfSites: 2)
        var errorOrNil: NSError?

        let url1 = urls[0].url
        let url2 = urls[1].url
        BrowserUtils.clearPrivateData(BrowserUtils.AllClearables.subtracting([BrowserUtils.Clearable.History]), swipe: false)
        tester().waitForAnimationsToFinish()
        BrowserUtils.openLibraryMenu(tester())
        // Open History Panel
        tester().tapView(withAccessibilityIdentifier: "LibraryPanels.History")
        tester().tapView(withAccessibilityIdentifier: "LibraryPanels.Bookmarks")
        tester().tapView(withAccessibilityIdentifier: "LibraryPanels.History")
        tester().waitForAnimationsToFinish()
        let historyListShown = GREYCondition(name: "Wait for history to appear", block: {
            var errorOrNil: NSError?
            EarlGrey.selectElement(with: grey_accessibilityLabel(url1))
                .assert(grey_notNil(), error: &errorOrNil)
            let success = errorOrNil == nil
            return success
        }).wait(withTimeout: 20)
        GREYAssertTrue(historyListShown, reason: "Failed to display history list")

        EarlGrey.selectElement(with: grey_accessibilityLabel(url1))
            .assert(grey_notNil(), error: &errorOrNil)
        EarlGrey.selectElement(with: grey_accessibilityLabel(url2))
            .assert(grey_notNil(), error: &errorOrNil)

        // Close History (and so Library) panel
        BrowserUtils.closeLibraryMenu(tester())
    }

    func testClearsCookies() {
        let url = "\(webRoot!)/numberedPage.html?page=1"
        BrowserUtils.enterUrlAddressBar(typeUrl: url)
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        let webView = tester().waitForView(withAccessibilityLabel: "Web content") as! WKWebView

        // Set and verify a dummy cookie value.
        setCookies(webView, cookie: "foo=bar")
        var cookies = getCookies(webView)
        XCTAssertEqual(cookies.cookie, "foo=bar")
        XCTAssertEqual(cookies.localStorage, "foo=bar")
        XCTAssertEqual(cookies.sessionStorage, "foo=bar")

        // Verify that cookies are not cleared when Cookies is deselected.
        BrowserUtils.clearPrivateData(BrowserUtils.AllClearables.subtracting([BrowserUtils.Clearable.Cookies]), swipe: false)
        cookies = getCookies(webView)
        XCTAssertEqual(cookies.cookie, "foo=bar")
        XCTAssertEqual(cookies.localStorage, "foo=bar")
        XCTAssertEqual(cookies.sessionStorage, "foo=bar")

        // Verify that cookies are cleared when Cookies is selected.
        BrowserUtils.clearPrivateData([BrowserUtils.Clearable.Cookies], swipe: false)
        cookies = getCookies(webView)
        XCTAssertEqual(cookies.cookie, "")
        XCTAssertEqual(cookies.localStorage, "null")
        XCTAssertEqual(cookies.sessionStorage, "null")
    }

    func testClearsCache() {
        let cachedServer = CachedPageServer()
        let cacheRoot = cachedServer.start()
        let url = "\(cacheRoot)/cachedPage.html"
        BrowserUtils.enterUrlAddressBar(typeUrl: url)
        tester().waitForWebViewElementWithAccessibilityLabel("Cache test")

        let webView = tester().waitForView(withAccessibilityLabel: "Web content") as! WKWebView
        let requests = cachedServer.requests

        // Verify that clearing non-cache items will keep the page in the cache.
        BrowserUtils.clearPrivateData(BrowserUtils.AllClearables.subtracting([BrowserUtils.Clearable.Cache]), swipe: false)
        webView.reload()
        XCTAssertEqual(cachedServer.requests, requests)

        // Verify that clearing the cache will fire a new request.
        BrowserUtils.clearPrivateData([BrowserUtils.Clearable.Cache], swipe: false)
        webView.reload()
        XCTAssertEqual(cachedServer.requests, requests + 1)
    }

    fileprivate func setCookies(_ webView: WKWebView, cookie: String) {
        let expectation = self.expectation(description: "Set cookie")
        webView.evaluateJavascriptInDefaultContentWorld("document.cookie = \"\(cookie)\"; localStorage.cookie = \"\(cookie)\"; sessionStorage.cookie = \"\(cookie)\";") { result, _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    fileprivate func getCookies(_ webView: WKWebView) -> (cookie: String, localStorage: String?, sessionStorage: String?) {
        var cookie: (String, String?, String?)!
        var value: String!
        let expectation = self.expectation(description: "Got cookie")

        webView.evaluateJavascriptInDefaultContentWorld("JSON.stringify([document.cookie, localStorage.cookie, sessionStorage.cookie])") { result, _ in
            value = result as! String
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
        value = value.replacingOccurrences(of: "[", with: "")
        value = value.replacingOccurrences(of: "]", with: "")
        value = value.replacingOccurrences(of: "\"", with: "")
        let items = value.components(separatedBy: ",")
        cookie = (items[0], items[1], items[2])
        return cookie
    }

    func testClearsTrackingProtectionSafelist() {
        let wait = expectation(description: "wait for file write")
        ContentBlocker.shared.safelist(enable: true, url: URL(string: "http://www.mozilla.com")!) {
            wait.fulfill()
        }
        waitForExpectations(timeout: 5)

        BrowserUtils.clearPrivateData([BrowserUtils.Clearable.TrackingProtection], swipe: false)

        let data = ContentBlocker.shared.readSafelistFile()
        XCTAssert(data == nil || data!.isEmpty)
    }

}

/// Server that keeps track of requests.
private class CachedPageServer {
    var requests = 0

    func start() -> String {
        let webServer = GCDWebServer()
        webServer.addHandler(forMethod: "GET", path: "/cachedPage.html", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            self.requests += 1
            return GCDWebServerDataResponse(html: "<html><head><title>Cached page</title></head><body>Cache test</body></html>")
        }

        webServer.start(withPort: 0, bonjourName: nil)

        // We use 127.0.0.1 explicitly here, rather than localhost, in order to avoid our
        // history exclusion code (Bug 1188626).
        let port = (webServer.port)
        let webRoot = "http://127.0.0.1:\(port)"
        return webRoot
    }
}
