// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Redux

enum AppScreenState: Equatable {
   case themeSettings(ThemeSettingsState)

    static let reducer: Reducer<Self> = { state, action in
        switch state {
        case .themeSettings(let state): return .themeSettings(ThemeManagerState.reducer(state, action))
        }
    }
}

struct ActiveScreensState: Equatable {
    let screens: [AppScreenState]

    static let reducer: Reducer<Self> = { state, action in
        var screens = state.screens

        if let action = action as? ActiveScreensStateAction {
            switch action {
            case .showThemeSettings(.themeSettings):
                screens = [.themeSettings(ThemeManagerState())]
            case .closeThemeSettings(.themeSettings):
                break
            }
        }

        return ActiveScreensState(screens: screens)
    }
}

extension ActiveScreensState {
    init() {
        screens = []
    }
}
