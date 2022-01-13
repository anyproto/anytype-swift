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
    static let blockCreate = "CreateBlock"
    static let blockBookmarkFetch = "BlockBookmarkFetch"

    static let blockMerge = "BlockMerge"
    static let blockDelete = "DeleteBlock"

    static let blockListDuplicate = "DuplicateBlock"
    static let blockListSetAlign = "ChangeBlockAlign"
    static let blockListSetBackgroundColor = "ChangeBlockBackground"
    static let blockSetDetails = "BlockSetDetails"
    static let blockSetTextChecked = "BlockSetTextChecked"
    static let blockUpload = "UploadMedia"
    static let downloadFile = "DownloadMedia"

    static let blockSetTextText = "Writing"
    static let changeBlockStyle = "ChangeBlockStyle"
    static let changeTextStyle = "ChangeTextStyle"

    static let pageCreate = "PageCreate"
    static let blockCreatePage = "BlockCreatePage"

    static let blockListSetDivStyle = "BlockListSetDivStyle"
    static let blockListConvertChildrenToPages = "BlockListConvertChildrenToPages"

    static let reorderBlock = "ReorderBlock"

    // Relation events
    static let addExistingRelation = "AddExistingRelation"
    static let createRelation = "CreateRelation"
    static let changeRelationValue = "ChangeRelationValue"
    static let deleteRelationValue = "DeleteRelationValue"
    static let deleteRelation = "DeleteRelation"


    // Object events
    static let addToFavorites = "AddToFavorites"
    static let removeFromFavorites = "RemoveFromFavorites"
    static let moveToBin = "MoveToBin"
    static let restoreFromBin = "RestoreFromBin"
    static let objectListDelete = "RemoveCompletely"
    static let defaultObjectTypeChange = "DefaultTypeChange"
    static let objectTypeChange = "ChangeObjectType"
    static let searchQuery = "SearchQuery"
    static let searchResult = "SearchResult"
    static let showObject = "ScreenObject"
    static let setLayoutAlign = "SetLayoutAlign"
    static let setIcon = "SetIcon"
    static let removeIcon = "RemoveIcon"
    static let setCover = "SetCover"
    static let removeCover = "RemoveCover"
    static let addFeatureRelation = "Feature relation"
    static let removeFeatureRelation = "Unfeature relation"

    // Details events
    static let changeLayout = "ChangeLayout"

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

    // Settings object events
    static let buttonCoverInObjectSettings = "ButtonCoverInObjectSettings"
    static let buttonIconInObjectSettings = "ButtonIconInObjectSettings"
    static let buttonLayoutInObjectSettings = "ButtonLayoutInObjectSettings"
    static let buttonRelationsInObjectSettings = "ButtonRelationsInObjectSettings"

    // Dashboard view events
    static let selectHomeTab = "SelectHomeTab"
    static let reorderObjects = "ReorderObjects" // reorder in favorite tab

    static let profilePage = "Page: Profile"

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

    static let searchShow = "ScreenSearch"
    static let showAboutScreen = "Show About Screen"
    static let objectRelationShow = "ScreenObjectRelation"

    // Navigation events
    static let goBack = "HistoryBack"
    static let goForward = "HistoryForward"

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

// MARK: - Search context

enum AmplitudeEventsSearchContext: String {
    case home = "home"
    case defaultType = "defaultType"
    case moveTo = "moveTo"
    case searchInObject = "searchInObject"
    case mention = "mention"
    case linkTo = "linkTo"
    case markupLinkTo = "markupLinkTo"
    case changeObjectType = "changeObjectType"
    case relation = "relation"
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
    static let length = "length"
    static let index = "index"
    static let layout = "layout"
    static let align = "align"
    static let format = "format"
}
