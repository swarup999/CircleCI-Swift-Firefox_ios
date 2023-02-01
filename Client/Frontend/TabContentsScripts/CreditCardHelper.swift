// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import Shared
import WebKit

class CreditCardHelper: TabContentScript {
    fileprivate weak var tab: Tab?

    class func name() -> String {
        return "CreditCardHelper"
    }

    required init(tab: Tab) {
        self.tab = tab
    }

    func scriptMessageHandlerName() -> String? {
        return "creditCardMessageHandler"
    }

    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let request = message.body as? [String: Any] else {return}
        print("Received from content script: ", request)

        // TODO: Retrieve response value from user selected credit card
        // Example value: [
        //     "data": [
        //         "cc-name": "Jane Doe",
        //         "cc-number": "5555555555554444",
        //         "cc-exp-month": "05",
        //         "cc-exp-year": "2028",
        //       ],
        //     "id": request["id"]!,
        // ]
        let response: [String: Any] = [:]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: "asd")
            guard let jsonDataVal = String(data: jsonData, encoding: .utf8) else { return }
            let fillCreditCardInfoCallback = "window.__firefox__.CreditCardHelper.fillCreditCardInfo('\(jsonDataVal)')"
            guard let webView = tab?.webView else {return}
            webView.evaluateJavascriptInDefaultContentWorld(fillCreditCardInfoCallback)
        } catch let error as NSError {
          print(error)
        }
    }
}
