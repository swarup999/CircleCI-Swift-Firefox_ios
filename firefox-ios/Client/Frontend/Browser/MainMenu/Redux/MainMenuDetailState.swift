// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import MenuKit
import Shared
import Redux

protocol Updating {
    associatedtype UpdateData
    func updating(with data: UpdateData) -> Self
    func withoutUpdates() -> Self
}

struct MainMenuDetailsState: ScreenState, Equatable, Updating {
    var windowUUID: WindowUUID
    var menuElements: [MenuSection]
    var shouldDismiss: Bool
    var shouldGoBackToMainMenu: Bool
    var navigationDestination: MainMenuNavigationDestination?
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
            navigationDestination: currentState.navigationDestination,
            shouldDismiss: currentState.shouldDismiss,
            shouldGoBackToMainMenu: currentState.shouldGoBackToMainMenu
        )
    }

    init(windowUUID: WindowUUID) {
        self.init(
            windowUUID: windowUUID,
            menuElements: [],
            submenuType: nil,
            navigationDestination: nil,
            shouldDismiss: false,
            shouldGoBackToMainMenu: false
        )
    }

    private init(
        windowUUID: WindowUUID,
        menuElements: [MenuSection],
        submenuType: MainMenuDetailsViewType?,
        navigationDestination: MainMenuNavigationDestination?,
        shouldDismiss: Bool,
        shouldGoBackToMainMenu: Bool
    ) {
        self.windowUUID = windowUUID
        self.menuElements = menuElements
        self.submenuType = submenuType
        self.navigationDestination = navigationDestination
        self.shouldDismiss = shouldDismiss
        self.shouldGoBackToMainMenu = shouldGoBackToMainMenu
    }

    // MARK: - Updating protocol
    struct UpdateData {
        let menuElements: [MenuSection]?
        let shouldDismiss: Bool
        let shouldGoBackToMainMenu: Bool
        let submenuType: MainMenuDetailsViewType?

        init(
            menuElements: [MenuSection]? = nil,
            shouldDismiss: Bool = false,
            shouldGoBackToMainMenu: Bool = false,
            submenuType: MainMenuDetailsViewType? = nil
        ) {
            self.menuElements = menuElements
            self.shouldDismiss = shouldDismiss
            self.shouldGoBackToMainMenu = shouldGoBackToMainMenu
            self.submenuType = submenuType
        }
    }

    func updating(with data: MainMenuDetailsState.UpdateData) -> MainMenuDetailsState {
        return MainMenuDetailsState(
            windowUUID: self.windowUUID,
            menuElements: data.menuElements ?? self.menuElements,
            submenuType: data.submenuType ?? self.submenuType,
            navigationDestination: nil,
            shouldDismiss: data.shouldDismiss,
            shouldGoBackToMainMenu: data.shouldGoBackToMainMenu
        )
    }

    func withoutUpdates() -> MainMenuDetailsState {
        return MainMenuDetailsState(
            windowUUID: windowUUID,
            menuElements: menuElements,
            submenuType: submenuType,
            navigationDestination: nil,
            shouldDismiss: false,
            shouldGoBackToMainMenu: false
        )
    }

    // MARK: - Reducer
    static let reducer: Reducer<Self> = { state, action in
        guard action.windowUUID == .unavailable || action.windowUUID == state.windowUUID else {
            return state.withoutUpdates()
        }
        typealias UpdateData = MainMenuDetailsState.UpdateData

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
