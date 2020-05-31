/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Foundation
import Account
import MozillaAppServices
import Shared
import SwiftKeychainWrapper


extension URL {
    var toRequest: URLRequest {
        return URLRequest(url: self)
    }
    /// Figuring out if two urls are the same based on scheme, host and path.
    func isEquivilent(to url: URL) -> Bool {
        return self.scheme == url.scheme &&
        self.host == url.host &&
        self.path == url.path
    }
}

enum FxAPageType {
    case emailLoginFlow
    case qrCode(url: String)
    case settingsPage
}

// See https://mozilla.github.io/ecosystem-platform/docs/fxa-engineering/fxa-webchannel-protocol
// For details on message types.
fileprivate enum RemoteCommand: String {
    //case canLinkAccount = "can_link_account"
    // case loaded = "fxaccounts:loaded"
    case status = "fxaccounts:fxa_status"
    case login = "fxaccounts:oauth_login"
    case changePassword = "fxaccounts:change_password"
    case signOut = "fxaccounts:logout"
    case deleteAccount = "fxaccounts:delete_account"
    case profileChanged = "profile:change"
}

typealias STATE = (URLRequest, UnifiedTelemetry.EventMethod?)

class FxAWebViewModel {
    
    fileprivate let pageType: FxAPageType
    fileprivate let profile: Profile
    fileprivate let firefoxAccounts: RustFirefoxAccounts
    
    /**
    init() FxAWebView.

    - parameter pageType: Specify login flow or settings page if already logged in.
    - parameter profile: a Profile.
    - parameter firefoxAccounts:
    */
    init(pageType: FxAPageType, profile: Profile, firefoxAccounts: RustFirefoxAccounts) {
        self.pageType = pageType
        self.profile = profile
        self.firefoxAccounts = firefoxAccounts
        
        // If accountMigrationFailed then the app menu has a caution icon,
        // and at this point the user has taken sufficient action to clear the caution.
        firefoxAccounts.accountMigrationFailed = false
    }
    
    fileprivate(set) var baseURL: URL?
    
    /// onEmittingNewState carries out the new state computed from invoking `authenticate`
    var onEmittingNewState: ((STATE) -> Void)?
    
    var onDismissController: (() -> Void)?
    var onWantingToExecuteJSScriptString: ((String) -> Void)?
    
    func authenticate() {
        firefoxAccounts.accountManager.uponQueue(.main) { accountManager in
            accountManager.getManageAccountURL(entrypoint: "ios_settings_manage") { [weak self] result in
                guard let self = self else { return }
                
                // Handle authentication with either the QR code login flow, email login flow, or settings page flow
                switch self.pageType {
                case .emailLoginFlow:
                    accountManager.beginAuthentication { [weak self] result in
                        if case .success(let url) = result {
                            self?.baseURL = url
                            self?.onEmittingNewState?((url.toRequest, .emailLogin))
                        }
                    }
                case let .qrCode(url):
                    accountManager.beginPairingAuthentication(pairingUrl: url) { [weak self] result in
                        if case .success(let url) = result {
                            self?.baseURL = url
                            self?.onEmittingNewState?((url.toRequest, .qrPairing))
                        }
                    }
                case .settingsPage:
                    if case .success(let url) = result {
                        self.baseURL = url
                        self.onEmittingNewState?((url.toRequest, nil))
                    }
                }
            }
        }
    }
}

extension FxAWebViewModel {
    
    func parseOrignAndExecuteRemoteCommand(basedOn message: WKScriptMessage) {
        guard let url = baseURL else { return }
        
        let origin = message.frameInfo.securityOrigin
        guard origin.`protocol` == url.scheme && origin.host == url.host && origin.port == (url.port ?? 0) else {
            print("Ignoring message - \(origin) does not match expected origin: \(url.origin ?? "nil")")
            return
        }
        
        guard message.name == "accountsCommandHandler" else { return }
        guard let body = message.body as? [String: Any], let detail = body["detail"] as? [String: Any],
            let msg = detail["message"] as? [String: Any], let cmd = msg["command"] as? String else {
                return
        }
        
        let id = Int(msg["messageId"] as? String ?? "")
        handleRemote(command: cmd, id: id, data: msg["data"])
    }
    
    // Handle a message coming from the content server.
    private func handleRemote(command rawValue: String, id: Int?, data: Any?) {
        if let command = RemoteCommand(rawValue: rawValue) {
            switch command {
            case .login:
                if let data = data {
                    onLogin(data: data)
                }
            case .changePassword:
                if let data = data {
                    onPasswordChange(data: data)
                }
            case .status:
                if let id = id {
                    onSessionStatus(id: id)
                }
            case .deleteAccount, .signOut:
                profile.removeAccount()
                onDismissController?()
            case .profileChanged:
                firefoxAccounts.accountManager.peek()?.refreshProfile(ignoreCache: true)
            }
        }
    }

    /// Send a message to web content using the required message structure.
    private func runJS(typeId: String, messageId: Int, command: String, data: String = "{}") {
        let msg = """
            var msg = {
                id: "\(typeId)",
                message: {
                    messageId: \(messageId),
                    command: "\(command)",
                    data : \(data)
                }
            };
            window.dispatchEvent(new CustomEvent('WebChannelMessageToContent', { detail: JSON.stringify(msg) }));
        """

        onWantingToExecuteJSScriptString?(msg)
    }

    /// Respond to the webpage session status notification by either passing signed in user info (for settings), or by passing CWTS setup info (in case the user is signing up for an account). This latter case is also used for the sign-in state.
    private func onSessionStatus(id: Int) {
        guard let fxa = firefoxAccounts.accountManager.peek() else { return }
        let cmd = "fxaccounts:fxa_status"
        let typeId = "account_updates"
        let data: String
        switch pageType {
            case .settingsPage:
                // Both email and uid are required at this time to properly link the FxA settings session
                let email = fxa.accountProfile()?.email ?? ""
                let uid = fxa.accountProfile()?.uid ?? ""
                let token = (try? fxa.getSessionToken().get()) ?? ""
                data = """
                {
                    capabilities: {},
                    signedInUser: {
                        sessionToken: "\(token)",
                        email: "\(email)",
                        uid: "\(uid)",
                        verified: true,
                    }
                }
            """
            case .emailLoginFlow, .qrCode:
                data = """
                    { capabilities:
                        { choose_what_to_sync: true, engines: ["bookmarks", "history", "tabs", "passwords"] },
                    }
                """
        }

        runJS(typeId: typeId, messageId: id, command: cmd, data: data)
    }

    private func onLogin(data: Any) {
        guard let data = data as? [String: Any], let code = data["code"] as? String, let state = data["state"] as? String else {
            return
        }
        
        if let declinedSyncEngines = data["declinedSyncEngines"] as? [String] {
            // Stash the declined engines so on first sync we can disable them!
            UserDefaults.standard.set(declinedSyncEngines, forKey: "fxa.cwts.declinedSyncEngines")
        }
        
        // Use presence of key `offeredSyncEngines` to determine if this was a new sign-up.
        if let engines = data["offeredSyncEngines"] as? [String], engines.count > 0 {
            LeanPlumClient.shared.track(event: .signsUpFxa)
        } else {
            LeanPlumClient.shared.track(event: .signsInFxa)
        }
        LeanPlumClient.shared.set(attributes: [LPAttributeKey.signedInSync: true])
        
        let auth = FxaAuthData(code: code, state: state, actionQueryParam: "signin")
        firefoxAccounts.accountManager.peek()?.finishAuthentication(authData: auth) { _ in
            self.profile.syncManager.onAddedAccount()
            
            // ask for push notification
            KeychainWrapper.sharedAppContainerKeychain.removeObject(forKey: KeychainKey.apnsToken, withAccessibility: .afterFirstUnlock)
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                guard error == nil else {
                    return
                }
                if granted {
                    NotificationCenter.default.post(name: .RegisterForPushNotifications, object: nil)
                }
            }
        }
        
        onDismissController?()
    }
    
    private func onPasswordChange(data: Any) {
        guard let data = data as? [String: Any], let sessionToken = data["sessionToken"] as? String else {
            return
        }
        
        firefoxAccounts.accountManager.peek()?.handlePasswordChanged(newSessionToken: sessionToken) {
            NotificationCenter.default.post(name: .RegisterForPushNotifications, object: nil)
        }
    }
    
    func shouldAllowRedirectAfterLogIn(basedOn navigationURL: URL?) -> Bool {
        // Cancel navigation that happens after login to an account, which is when a redirect to `redirectURL` happens.
        // The app handles this event fully in native UI.
        let redirectUrl = RustFirefoxAccounts.redirectURL
        if let navigationURL = navigationURL {
            let expectedRedirectURL = URL(string: redirectUrl)!
            if navigationURL.isEquivilent(to: expectedRedirectURL) {
                return false
            }
        }
        return true
    }
    
}
