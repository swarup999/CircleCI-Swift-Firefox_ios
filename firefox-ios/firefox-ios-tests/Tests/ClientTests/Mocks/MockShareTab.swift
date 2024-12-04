// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

@testable import Client

class MockShareTab: ShareTab {
    var displayTitle: String
    var url: URL?
    var webView: TabWebView?
    var temporaryDocument: TemporaryDocument?

    init(title: String, url: URL?, withActiveWebView: Bool = true, withTemporaryDocument: TemporaryDocument? = nil) {
        self.displayTitle = title
        self.url = url
        self.webView = TabWebView(frame: CGRect.zero, configuration: .init(), windowUUID: .XCTestDefaultUUID)
        self.temporaryDocument = withTemporaryDocument
    }

    static func == (lhs: MockShareTab, rhs: MockShareTab) -> Bool {
        return lhs.displayTitle == rhs.displayTitle
        && lhs.url == rhs.url
        && lhs.webView === rhs.webView
        && lhs.temporaryDocument === rhs.temporaryDocument
    }
}
