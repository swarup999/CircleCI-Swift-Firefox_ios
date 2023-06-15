// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// TODO: Following images are duplicates and need to be cleaned up
// - `action_bookmark_remove` and `menu-Bookmark-Remove`
// - `action_bookmark` and `menu-Bookmark`

/// This struct defines all the image identifiers of icons and images used in the app.
/// When adding new identifiers, please respect alphabetical order.
/// Sing the song if you must.
public struct ImageIdentifiers {
    public static let actionAddBookmark = "action_bookmark"
    public static let actionRemove = "action_remove"
    public static let actionRemoveBookmark = "action_bookmark_remove"
    public static let add = "add"
    public static let addShortcut = "action_pin"
    public static let addToBookmark = "menu-Bookmark"
    public static let addToReadingList = "addToReadingList"
    public static let badgeMask = "badge-mask"
    public static let bookmarks = "menu-panel-Bookmarks"
    public static let bookmarkFolder = "bookmarkFolder"
    public static let bottomSheetClose = "bottomSheet-close"
    public static let check = "check"
    public static let circleFill = "circle.fill"
    public static let closeLargeButton = "close-large"
    public static let closeMediumButton = "close-medium"
    public static let closeTap = "menu-CloseTabs"
    public static let contextualHintClose = "find_close"
    public static let copyLink = "menu-Copy-Link"
    public static let creditCardPlaceholder = "credit_card_placeholder"
    public static let customSwitchBackground = "menu-customswitch-background"
    public static let customSwitchOff = "menu-customswitch-off"
    public static let customSwitchOn = "menu-customswitch-on"
    public static let defaultFavicon = "defaultFavicon"
    public static let deviceTypeDesktop = "deviceTypeDesktop"
    public static let deviceTypeMobile = "deviceTypeMobile"
    public static let downloads = "menu-panel-Downloads"
    public static let edit = "edit"
    public static let errorAutofill = "error_autofill"
    public static let emptySyncImageName = "emptySync"
    public static let findInPage = "menu-FindInPage"
    public static let findNext = "find_next"
    public static let findPrevious = "find_previous"
    public static let firefoxFavicon = "faviconFox"
    public static let help = "help"
    public static let history = "menu-panel-History"
    public static let homeHeaderLogoBall = "fxHomeHeaderLogoBall"
    public static let homeHeaderLogoText = "fxHomeHeaderLogoText"
    public static let homepagePocket = "homepage-pocket"
    public static let key = "key"
    public static let largePrivateTabsMask = "largePrivateMask"
    public static let libraryBookmarks = "library-bookmark"
    public static let libraryDownloads = "library-downloads"
    public static let libraryHistory = "library-history"
    public static let libraryPanelDelete = "action_delete"
    public static let libraryPanelHistory = "library-history"
    public static let libraryPanelSearch = "search"
    public static let libraryReadingList = "library-readinglist"
    public static let lockBlocked = "lock_blocked"
    public static let lockVerifed = "lock_verified"
    public static let logo = "splash"
    public static let logoAmex = "logo_amex"
    public static let logoDiners = "logo_diners"
    public static let logoDiscover = "logo_discover"
    public static let logoJcb = "logo_jcb"
    public static let logoMastercard = "logo_mastercard"
    public static let logoMir = "logo_mir"
    public static let logoUnionpay = "logo_unionpay"
    public static let logoVisa = "logo_visa"
    public static let menuBadge = "menuBadge"
    public static let menuChevron = "menu-Disclosure"
    public static let menuGoBack = "goBack"
    public static let menuScanQRCode = "menu-ScanQRCode"
    public static let menuWarning = "menuWarning"
    public static let menuWarningMask = "warning-mask"
    public static let navAdd = "nav-add"
    public static let navTabCounter = "nav-tabcounter"
    public static let navMenu = "nav-menu"
    public static let newPrivateTab = "quick_action_new_private_tab"
    public static let newTab = "quick_action_new_tab"
    public static let nightMode = "menu-NightMode"
    public static let noImageMode = "menu-NoImageMode"
    public static let onboardingWelcomev106 = "onboardingWelcome"
    public static let onboardingSyncv106 = "onboardingSync"
    public static let onboardingNotification = "onboardingNotification"
    public static let onboardingNotificationsCTD = "onboardingNotificationsCTD"
    public static let onboardingWelcomeCTD = "onboardingWelcomeCTD"
    public static let onboardingSyncCTD = "onboardingSyncCTD"
    public static let paste = "menu-Paste"
    public static let pasteAndGo = "menu-PasteAndGo"
    public static let pinSmall = "pin_small"
    public static let placeholderAvatar = "placeholder-avatar"
    public static let qrCodeScanBorder = "qrcode-scanBorder"
    public static let qrCodeScanLine = "qrcode-scanLine"
    public static let qrCodeGoBack = "qrcode-goBack"
    public static let qrCodeLight = "qrcode-light"
    public static let qrCodeLightTurnedOn = "qrcode-isLighting"
    public static let privateMaskSmall = "smallPrivateMask"
    public static let privateModeBadge = "privateModeBadge"
    public static let readingList = "menu-panel-ReadingList"
    public static let removeFromBookmark = "menu-Bookmark-Remove"
    public static let removeFromReadingList = "removeFromReadingList"
    public static let removeFromShortcut = "action_unpin"
    public static let reportSiteIssue = "menu-reportSiteIssue"
    public static let requestDesktopSite = "menu-RequestDesktopSite"
    public static let requestMobileSite = "menu-ViewMobile"
    public static let sendToDevice = "menu-Send-to-Device"
    public static let settings = "menu-Settings"
    public static let share = "action_share"
    public static let signinSync = "signin-sync"
    public static let signinSyncQRButton = "qr-code-icon-white"
    public static let sponsoredStar = "sponsored-star"
    public static let stackedTabsIcon = "recently_closed"
    public static let subtract = "subtract"
    public static let sync = "menu-sync"
    public static let syncedDevicesIcon = "synced_devices"
    public static let tabTrayDelete = "action_delete"
    public static let tabTrayNewTab = "menu-NewTab"
    public static let trashIcon = "forget"
    public static let trashIconMonochrome = "trash-icon"
    public static let upgradeBackground = "onboardingBackground"
    public static let upgradeCloseButton = "updateCloseButton"
    public static let warning = "menu-warning"
    public static let breachedWebsite = "Breached Website"
    public static let whatsNew = "whatsnew"
    public static let xMark = "nav-stop"
    public static let zoomIn = "menu-ZoomIn"
}
