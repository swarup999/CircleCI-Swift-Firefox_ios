// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import MenuKit
import Shared
import Redux

// This would live on `ScreenState`, rather than each individual state
// But I just applied it here to keep the proposal small.
// With, likely, better naming.
protocol Updating {
    associatedtype UpdateData
    func updating(with data: UpdateData) -> Self
    func withoutUpdates() -> Self
}

struct MainMenuDetailsState: ScreenState, Equatable, Updating {
    // at first, we do the regular setup for state stuff
    var windowUUID: WindowUUID
    var menuElements: [MenuSection]
    var shouldDismiss: Bool
    var shouldGoBackToMainMenu: Bool
    var submenuType: MainMenuDetailsViewType?

    var title: String {
        typealias Titles = String.MainMenu.ToolsSection
        return submenuType == .tools ? Titles.Tools : Titles.Save
    }

    private let menuConfigurator = MainMenuConfigurationUtility()

    init(appState: AppState, uuid: WindowUUID) {
        guard let currentState = store.state.screenState(
            MainMenuDetailsState.self,
            for: .mainMenuDetails,
            window: uuid
        ) else {
            self.init(windowUUID: uuid)
            return
        }

        self.init(
            windowUUID: currentState.windowUUID,
            menuElements: currentState.menuElements,
            submenuType: currentState.submenuType,
            shouldDismiss: currentState.shouldDismiss,
            shouldGoBackToMainMenu: currentState.shouldGoBackToMainMenu
        )
    }

    init(windowUUID: WindowUUID) {
        self.init(
            windowUUID: windowUUID,
            menuElements: [],
            submenuType: nil,
            shouldDismiss: false,
            shouldGoBackToMainMenu: false
        )
    }

    // We remove the default initializers from here, because we already provide
    // a default starting point with the `init` and then we provide separate
    // defaults with the `Updating` stuff.
    private init(
        windowUUID: WindowUUID,
        menuElements: [MenuSection],
        submenuType: MainMenuDetailsViewType?,
        shouldDismiss: Bool,
        shouldGoBackToMainMenu: Bool
    ) {
        self.windowUUID = windowUUID
        self.menuElements = menuElements
        self.submenuType = submenuType
        self.shouldDismiss = shouldDismiss
        self.shouldGoBackToMainMenu = shouldGoBackToMainMenu
    }

    // MARK: - Updating protocol
    // makes associated type easier to type
    typealias UpdateData = MainMenuDetailsState.UpdateableData

    // Specifiy the updating data associated type for each state individually.
    // We have to specify `nil` in the initializer because Swift is a dumb
    // language sometimes, and, cannot infer that these can just be nil
    // in the initializer by marking them optional or the compiler yells at you
    // about arguments. le sigh
    struct UpdateableData {
        // we only add elements that are updateable for the state. For example,
        // window UUID never changes, so we don't actually update that
        let menuElements: [MenuSection]?
        let shouldDismiss: Bool?
        let shouldGoBackToMainMenu: Bool?
        let submenuType: MainMenuDetailsViewType?

        init(
            menuElements: [MenuSection]? = nil,
            shouldDismiss: Bool? = nil,
            shouldGoBackToMainMenu: Bool? = nil,
            submenuType: MainMenuDetailsViewType? = nil
        ) {
            self.menuElements = menuElements
            self.shouldDismiss = shouldDismiss
            self.shouldGoBackToMainMenu = shouldGoBackToMainMenu
            self.submenuType = submenuType
        }
    }

    // this is used when making one or more in the state. We also provide
    // the default initializer, basically, for the updating condition.
    func updating(with data: MainMenuDetailsState.UpdateData) -> MainMenuDetailsState {
        return MainMenuDetailsState(
            windowUUID: self.windowUUID,
            menuElements: data.menuElements ?? self.menuElements,
            submenuType: data.submenuType ?? self.submenuType,
            shouldDismiss: data.shouldDismiss ?? false,
            shouldGoBackToMainMenu: data.shouldGoBackToMainMenu ?? false
        )
    }

    // used for when we don't have any updates to the state. Acting as an exit
    // type function, returning a default implementation of state that we want
    // on any non-updating returns
    func withoutUpdates() -> MainMenuDetailsState {
        return MainMenuDetailsState(
            windowUUID: windowUUID,
            menuElements: menuElements,
            submenuType: submenuType,
            shouldDismiss: false,
            shouldGoBackToMainMenu: false
        )
    }

    // MARK: - Reducer
    static let reducer: Reducer<Self> = { state, action in
        guard action.windowUUID == .unavailable || action.windowUUID == state.windowUUID else {
            return state.withoutUpdates()
        }

        switch action.actionType {
        case ScreenActionType.showScreen:
            guard let screenAction = action as? ScreenAction,
                  screenAction.screen == .mainMenuDetails,
                  let menuState = store.state.screenState(
                    MainMenuState.self,
                    for: .mainMenu,
                    window: action.windowUUID),
                  let currentTabInfo = menuState.currentTabInfo,
                  let currentSubmenu = menuState.currentSubmenuView
            else {
                return state.withoutUpdates()
            }

            return state.updating(
                with: UpdateData(
                    menuElements: state.menuConfigurator.generateMenuElements(
                        with: currentTabInfo,
                        for: currentSubmenu,
                        and: action.windowUUID
                    ),
                    submenuType: currentSubmenu
                )
            )
        case MainMenuDetailsActionType.backToMainMenu:
            return state.updating(with: UpdateData(shouldGoBackToMainMenu: true))
        case MainMenuDetailsActionType.dismissView:
            return state.updating(with: UpdateData(shouldDismiss: true))
        default:
            return state.withoutUpdates()
        }
    }
}
