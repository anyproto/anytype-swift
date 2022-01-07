// MARK: - API Key

enum AmplitudeConfiguration {
    static let devAPIKey = "827af3255d76ef87541cd459a0a38242"
    static let prodAPIKey = "1ba981d1a9afb8af8c81847ef3383a20"
}

// MARK: - Events name

enum AmplitudeEventsName {
    // Auth events
    static let createAccount = "CreateAccount"
    static let openAccount = "OpenAccount"
    static let logout = "LogOut"

    // Block events
    static let blockCreate = "BlockCreate"
    static let blockBookmarkFetch = "BlockBookmarkFetch"
    static let blockListDuplicate = "BlockListDuplicate"
    static let blockCreatePage = "BlockCreatePage"
    static let blockListConvertChildrenToPages = "BlockListConvertChildrenToPages"
    static let blockListSetAlign = "BlockListSetAlign"
    static let blockListSetBackgroundColor = "BlockListSetBackgroundColor"
    static let blockListSetDivStyle = "BlockListSetDivStyle"
    static let blockMerge = "BlockMerge"
    static let blockSetDetails = "BlockSetDetails"
    static let blockSetTextChecked = "BlockSetTextChecked"
    static let blockSetTextStyle = "BlockSetTextStyle"
    static let blockSetTextText = "BlockSetTextText"
    static let blockSplit = "BlockSplit"
    static let blockUnlink = "BlockUnlink"
    static let blockUpload = "BlockUpload"
    static let downloadFile = "DownloadFile"
    static let pageCreate = "PageCreate"

    // Object events
    static let addToFavorites = "AddToFavorites"
    static let removeFromFavorites = "RemoveFromFavorites"
    static let moveToBin = "MoveToBin"
    static let restoreFromBin = "RestoreFromBin"
    static let objectListDelete = "RemoveCompletely"
    static let defaultObjectTypeChange = "DefaultTypeChange"

    // App settings events
    static let selectTheme = "ThemeSet"
    static let clearFileCacheAlertShow = "ScreenFileOffloadWarning"
    static let fileCacheCleared = "FileOffload"

    // Events in editing accessory view
    static let buttonSlashMenu = "ButtonSlashMenu"
    static let buttonStyleMenu = "ButtonStyleMenu"
    static let buttonMentionMenu = "ButtonMentionMenu"
    static let buttonHideKeyboard = "ButtonHideKeyboard"

    // Profile events
    static let buttonProfileLogOut = "ButtonProfileLogOut"

    // Emoji picker events
    static let buttonRandomEmoji = "ButtonRandomEmoji"
    static let buttonRemoveEmoji = "ButtonRemoveEmoji"
    static let buttonUploadPhoto = "ButtonUploadPhoto"

    // Settings object events
    static let buttonCoverInObjectSettings = "ButtonCoverInObjectSettings"
    static let buttonIconInObjectSettings = "ButtonIconInObjectSettings"
    static let buttonLayoutInObjectSettings = "ButtonLayoutInObjectSettings"
    static let buttonRelationsInObjectSettings = "ButtonRelationsInObjectSettings"

    // Dashboard view events
    static let selectHomeTab = "SelectHomeTab"
    static let reorderObjects = "ReorderObjects" // reorder in favorite tab

    static let profilePage = "Page: Profile"
    static let documentPage = "Page: Document"

    // Screen show events
    static let disclaimerShow = "ScreenDisclaimer"
    static let authScreenShow = "ScreenIndex"
    static let loginScreenShow = "ScreenLogin"
    static let signupScreenShow = "ScreenAuthRegistration"
    static let invitaionScreenShow = "ScreenAuthInvitation"

    static let homeShow = "ScreenHome"
    static let settingsShow = "ScreenSettings"
    static let otherSettingsShow = "ScreenSettingsOther"
    static let wallpaperSettingsShow = "ScreenSettingsWallpaper"
    static let deletionWarningShow = "ShowDeletionWarning"

    static let keychainPhraseScreenShow = "ScreenKeychain"
    static let keychainPhraseCopy = "KeychainCopy"

    static let showAboutScreen = "Show About Screen"

    // Popup events
    static let popupSlashMenu = "PopupSlashMenu"
    static let popupActionMenu = "PopupActionMenu"
    static let popupBookmarkMenu = "PopupBookmarkMenu"
    static let popupDocumentMenu = "PopupDocumentMenu"
    static let popupChooseEmojiMenu = "PopupChooseEmojiMenu"
    static let popupChooseLayout = "PopupChooseLayout"
    static let popupChooseCover = "PopupChooseCover"
    static let popupStyleMenu = "PopupStyleMenu"
    static let popupMentionMenu = "PopupMentionMenu"
    static let popupProfileIconMenu = "PopupProfileIconMenu"
}

// MARK: - Home tab names

enum AmplitudeEventsHomeTabValue {
    static let favoritesTabSelected = "FavoritesTabSelected"
    static let archiveTabSelected = "ArchiveTabSelected"
    static let recentTabSelected = "RecentTabSelected"
    static let sharedTabSelected = "SharedTabSelected"
    static let setsTabSelected = "SetsTabSelected"
}

// MARK: - Keychain showing context

enum AmplitudeEventsKeychainContext: String {
    case settings = "ScreenSettings"
    case logout = "BeforeLogout"
    case signup = "FirstSession"
}

// MARK: - Properties key

enum AmplitudeEventsPropertiesKey {
    static let accountId = "accountId"
    static let blockStyle = "style"
    static let blockType = "type"
    static let documentId = "documentId"
    static let count = "count"

    static let tab = "tab"
    static let route = "route"

    static let type = "type"
    static let objectType = "objectType"
}
