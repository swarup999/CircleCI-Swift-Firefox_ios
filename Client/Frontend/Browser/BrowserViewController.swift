/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

private let StatusBarHeight = 20

class BrowserViewController: UIViewController, BrowserToolbarDelegate {
    var toolbar: BrowserToolbar!
    var browser: Browser!

    override func viewDidLoad() {
        toolbar = BrowserToolbar()
        view.addSubview(toolbar)

        browser = Browser()
        browser.view.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        view.addSubview(browser.view)

        toolbar.snp_makeConstraints { make in
            make.top.equalTo(self.view).offset(StatusBarHeight)
            make.height.equalTo(44)
            make.leading.trailing.equalTo(self.view)
        }

        browser.view.snp_makeConstraints { make in
            make.top.equalTo(self.toolbar.snp_bottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }

        toolbar.browserToolbarDelegate = self
        browser.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.mozilla.org")!))
    }
    override func observeValueForKeyPath(keyPath: String, ofObject object:
        AnyObject, change:[NSObject: AnyObject], context:
        UnsafeMutablePointer<Void>) {
            if keyPath == "estimatedProgress"{
                if let progress = change[NSKeyValueChangeNewKey] as Float? {
                    self.toolbar.updateProgressBar(progress)
                }
            } else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context:nil)
            }
    }
    
    deinit {
        browser.view.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
    }

    func didClickBack() {
        browser.goBack()
    }

    func didClickForward() {
        browser.goForward()
    }

    func didEnterURL(url: NSURL) {
        browser.loadRequest(NSURLRequest(URL: url))
    }
}