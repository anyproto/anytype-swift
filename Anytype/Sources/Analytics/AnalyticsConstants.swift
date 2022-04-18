// MARK: - API Key

enum AnalyticsConfiguration {
    static let devAPIKey = "827af3255d76ef87541cd459a0a38242"
    static let prodAPIKey = "1ba981d1a9afb8af8c81847ef3383a20"
}

// MARK: - Events name

enum AnalyticsEventsName {
    // Auth events
    static let createAccount = "CreateAccount"
    static let openAccount = "OpenAccount"
    static let logout = "LogOut"

    // Block events
    static let blockCreate = "CreateBlock"
    static let blockDelete = "DeleteBlock"

    static let blockListDuplicate = "DuplicateBlock"
    static let blockListSetAlign = "ChangeBlockAlign"
    static let blockListSetBackgroundColor = "ChangeBlockBackground"
    static let blockUpload = "UploadMedia"
    static let downloadFile = "DownloadMedia"

    static let blockSetTextText = "Writing"
    static let changeBlockStyle = "ChangeBlockStyle"
    static let changeTextStyle = "ChangeTextStyle"

    static let reorderBlock = "ReorderBlock"

    // Relation events
    static let addExistingRelation = "AddExistingRelation"
    static let createRelation = "CreateRelation"
    static let changeRelationValue = "ChangeRelationValue"
    static let deleteRelationValue = "DeleteRelationValue"
    static let deleteRelation = "DeleteRelation"


    // Object events
    static let createObject = "CreateObject"
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
    static let addFeatureRelation = "FeatureRelation"
    static let removeFeatureRelation = "UnfeatureRelation"

    // Details events
    static let changeLayout = "ChangeLayout"

    // App settings events
    static let selectTheme = "ThemeSet"
    static let clearFileCacheAlertShow = "ScreenFileOffloadWarning"
    static let fileCacheCleared = "FileOffload"

    // Dashboard view events
    static let selectHomeTab = "SelectHomeTab"
    static let reorderObjects = "ReorderObjects" // reorder in favorite tab

    // Screen show events
    static let disclaimerShow = "ScreenDisclaimer"
    static let authScreenShow = "ScreenIndex"
    static let loginScreenShow = "ScreenLogin"
    static let signupScreenShow = "ScreenAuthRegistration"
    static let invitaionScreenShow = "ScreenAuthInvitation"

    static let homeShow = "ScreenHome"
    static let settingsShow = "ScreenSettings"
    static let wallpaperSettingsShow = "ScreenSettingsWallpaper"
    static let accountSettingsShow = "ScreenSettingsAccount"
    static let personalizationSettingsShow = "ScreenSettingsPersonalization"
    static let appearanceSettingsShow = "ScreenSettingsAppearance"
    static let aboutSettingsShow = "ScreenSettingsAbout"
    
    static let deletionWarningShow = "ShowDeletionWarning"

    static let keychainPhraseScreenShow = "ScreenKeychain"
    static let keychainPhraseCopy = "KeychainCopy"

    static let searchShow = "ScreenSearch"
    static let objectRelationShow = "ScreenObjectRelation"

    // Navigation events
    static let goBack = "HistoryBack"
    static let goForward = "HistoryForward"
}

// MARK: - Home tab names

enum AnalyticsEventsHomeTabValue {
    static let favoritesTabSelected = "FavoritesTabSelected"
    static let archiveTabSelected = "ArchiveTabSelected"
    static let recentTabSelected = "RecentTabSelected"
    static let sharedTabSelected = "SharedTabSelected"
    static let setsTabSelected = "SetsTabSelected"
}

// MARK: - Keychain showing context

enum AnalyticsEventsKeychainContext: String {
    case settings = "ScreenSettings"
    case logout = "BeforeLogout"
    case signup = "FirstSession"
}

// MARK: - Search context

enum AnalyticsEventsSearchContext: String {
    /// General search
    case general = "ScreenSearch"
    case mention = "MenuMention"
    case menuSearch = "MenuSearch"
}

// MARK: - Properties key

enum AnalyticsEventsPropertiesKey {
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
