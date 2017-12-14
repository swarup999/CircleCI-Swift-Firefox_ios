/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import WebKit

class WindowHelper: TabContentScript {
    fileprivate weak var tab: Tab?

    class func name() -> String {
        return "WindowHelper"
    }

    required init(tab: Tab) {
        self.tab = tab
        if let path = Bundle.main.path(forResource: "WindowHelper", ofType: "js"), let source = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String {
            let userScript = WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
            tab.webView!.configuration.userContentController.addUserScript(userScript)
        }
    }

    func scriptMessageHandlerName() -> String? {
        return "windowHandler"
    }

     func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
     }
}

