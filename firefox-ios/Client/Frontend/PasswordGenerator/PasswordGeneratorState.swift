// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Redux
import Shared
import Common

struct PasswordGeneratorState: ScreenState, Equatable {
    var windowUUID: WindowUUID
    var password: String
    var passwordBlurred: Bool

    init(appState: AppState, uuid: WindowUUID) {
        guard let passwordGeneratorState = store.state.screenState(
            PasswordGeneratorState.self,
            for: .passwordGenerator,
            window: uuid
        ) else {
            self.init(windowUUID: uuid)
            return
        }

        self.init(
            windowUUID: passwordGeneratorState.windowUUID,
            password: passwordGeneratorState.password,
            passwordBlurred: passwordGeneratorState.passwordBlurred
        )
    }

    init(
        windowUUID: WindowUUID,
        password: String = "",
        passwordBlurred: Bool = false
    ) {
        self.windowUUID = windowUUID
        self.password = password
        self.passwordBlurred = passwordBlurred
    }

    static let reducer: Reducer<Self> = { state, action in
        guard action.windowUUID == .unavailable || action.windowUUID == state.windowUUID
        else { return defaultState(from: state) }

        switch action.actionType {
        case PasswordGeneratorActionType.updateGeneratedPassword:
            guard let password = (action as? PasswordGeneratorAction)?.password
            else {
                return defaultState(from: state)
            }
            return PasswordGeneratorState(
                windowUUID: action.windowUUID,
                password: password,
                passwordBlurred: state.passwordBlurred)

            case PasswordGeneratorActionType.blurPassword:
                return PasswordGeneratorState(
                    windowUUID: action.windowUUID,
                    password: state.password,
                    passwordBlurred: true)

            case PasswordGeneratorActionType.unblurPassword:
                return PasswordGeneratorState(
                    windowUUID: action.windowUUID,
                    password: state.password,
                    passwordBlurred: false)

        default:
            return defaultState(from: state)
        }
    }

    static func defaultState(from state: PasswordGeneratorState) -> PasswordGeneratorState {
        return PasswordGeneratorState(
            windowUUID: state.windowUUID,
            password: state.password,
            passwordBlurred: state.passwordBlurred
        )
    }
}
