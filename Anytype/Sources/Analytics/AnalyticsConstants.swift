// MARK: - API Key

enum AnalyticsConfiguration {
    static let apiKey = "AmplitudeApiKey"
}

// MARK: - Events name

enum AnalyticsEventsName {
    // Auth events
    static let createAccount = "CreateAccount"
    static let openAccount = "OpenAccount"
    static let logout = "LogOut"
    static let deleteAccount = "DeleteAccount"
    static let cancelDeletion = "CancelDeletion"
    static let screenOnboarding = "ScreenOnboarding"
    static let clickOnboarding = "ClickOnboarding"
    static let clickLogin = "ClickLogin"
    static let onboardingSkipName = "ScreenOnboardingSkipName"

    // Block events
    static let blockCreate = "CreateBlock"
    static let blockDelete = "DeleteBlock"
    static let createLink = "CreateLink"

    static let blockListDuplicate = "DuplicateBlock"
    static let blockListSetAlign = "ChangeBlockAlign"
    static let changeBlockBackground = "ChangeBlockBackground"
    static let blockUpload = "UploadMedia"
    static let downloadFile = "DownloadMedia"

    static let blockSetTextText = "Writing"
    static let changeBlockStyle = "ChangeBlockStyle"
    static let changeTextStyle = "ChangeTextStyle"

    static let reorderBlock = "ReorderBlock"
    static let blockBookmarkOpenUrl = "BlockBookmarkOpenUrl"
    static let openAsObject = "OpenAsObject"
    static let openAsSource = "OpenAsSource"
    static let copyBlock = "CopyBlock"
    static let pasteBlock = "PasteBlock"
    static let setObjectDescription = "SetObjectDescription"
    
    // Relation events
    static let addExistingRelation = "AddExistingRelation"
    static let createRelation = "CreateRelation"
    static let changeRelationValue = "ChangeRelationValue"
    static let deleteRelationValue = "DeleteRelationValue"
    static let deleteRelation = "DeleteRelation"
    
    // Templating
    static let selectTemplate = "SelectTemplate"
    static let changeDefaultTemplate = "ChangeDefaultTemplate"
    static let templateEditing = "EditTemplate"
    static let duplicateTemplate = "DuplicateTemplate"
    static let createTemplate = "CreateTemplate"

    // Object events
    static let createObject = "CreateObject"
    static let addToFavorites = "AddToFavorites"
    static let removeFromFavorites = "RemoveFromFavorites"
    static let moveToBin = "MoveToBin"
    static let restoreFromBin = "RestoreFromBin"
    static let objectListDelete = "RemoveCompletely"
    static let defaultObjectTypeChange = "DefaultTypeChange"
    static let objectTypeChange = "ChangeObjectType"
    static let selectObjectType = "SelectObjectType"
    static let showObject = "ScreenObject"
    static let setLayoutAlign = "SetLayoutAlign"
    static let setIcon = "SetIcon"
    static let removeIcon = "RemoveIcon"
    static let setCover = "SetCover"
    static let removeCover = "RemoveCover"
    static let addFeatureRelation = "FeatureRelation"
    static let removeFeatureRelation = "UnfeatureRelation"
    static let linkToObject = "LinkToObject"
    static let lockPage = "LockPage"
    static let unlockPage = "UnlockPage"
    static let undo = "Undo"
    static let redo = "Redo"
    static let duplicateObject = "DuplicateObject"
    static let moveBlock = "MoveBlock"
    
    // Type picker
    static let pinObjectType = "PinObjectType"
    static let unpinObjectType = "UnpinObjectType"
    static let typeSearchResult = "TypeSearchResult"

    // Details events
    static let changeLayout = "ChangeLayout"

    // App settings events
    static let selectTheme = "ThemeSet"
    static let screenFileOffloadWarning = "ScreenFileOffloadWarning"
    static let fileCacheCleared = "FileOffload"
    static let settingsStorageOffload = "SettingsStorageOffload"

    // Dashboard view events
    static let selectHomeTab = "SelectHomeTab"
    static let reorderObjects = "ReorderObjects" // reorder in favorite tab

    // Screen show events
    static let disclaimerShow = "ScreenDisclaimer"
    static let mainAuthScreenShow = "ScreenIndex"
    static let loginScreenShow = "ScreenLogin"
    static let screenAuthRegistration = "ScreenAuthRegistration"

    static let homeShow = "ScreenHome"
    static let screenDeletion = "ScreenDeletion"

    static let wallpaperSettingsShow = "ScreenSettingsWallpaper"
    static let screenSettingsAccount = "ScreenSettingsAccount"
    static let screenSettingsAccountAccess = "ScreenSettingsAccountAccess"
    static let screenSettingsPersonal = "ScreenSettingsPersonal"
    static let appearanceSettingsShow = "ScreenSettingsAppearance"
    static let menuHelp = "MenuHelp"
    static let screenSettingsDelete = "ScreenSettingsDelete"
    static let settingsWallpaperSet = "SettingsWallpaperSet"
    static let screenSettingsStorageIndex = "ScreenSettingsStorageIndex"
    static let screenSettingsStorageManager = "ScreenSettingsStorageManager"
    static let screenObjectTypeSearch = "ScreenObjectTypeSearch"
    
    static let showDeletionWarning = "ShowDeletionWarning"

    static let keychainPhraseScreenShow = "ScreenKeychain"
    static let keychainPhraseCopy = "KeychainCopy"

    static let screenSearch = "ScreenSearch"
    static let searchResult = "SearchResult"
    static let objectRelationShow = "ScreenObjectRelation"

    static let onboardingTooltip = "OnboardingTooltip"
    static let clickOnboardingTooltip = "ClickOnboardingTooltip"
    
    // Navigation events
    static let goBack = "HistoryBack"
    static let goForward = "HistoryForward"

    static let blockAction = "BlockAction"
    
    // Relation
    static let reloadSourceData = "ReloadSourceData"
    static let relationUrlOpen = "RelationUrlOpen"
    static let relationUrlCopy = "RelationUrlCopy"
    static let relationUrlEditMobile = "RelationUrlEditMobile"
    
    // Collection
    static let screenCollection = "ScreenCollection"
    
    // Set
    static let screenSet = "ScreenSet"
    static let setSelectQuery = "SetSelectQuery"
    static let setTurnIntoCollection = "SetTurnIntoCollection"
    
    // Set/Collection: Views
    static let addView = "AddView"
    static let switchView = "SwitchView"
    static let repositionView = "RepositionView"
    static let duplicateView = "DuplicateView"
    static let changeViewType = "ChangeViewType"
    static let removeView = "RemoveView"
    
    // Set/Collection: Filters
    static let addFilter = "AddFilter"
    static let сhangeFilterValue = "ChangeFilterValue"
    static let removeFilter = "RemoveFilter"
    
    // Set/Collection: Sorts
    static let addSort = "AddSort"
    static let changeSortValue = "ChangeSortValue"
    static let repositionSort = "RepositionSort"
    static let removeSort = "RemoveSort"

    // Migration
    static let migrationGoneWrong = "MigrationGoneWrong"
    
    // Space
    static let screenSettingsSpaceCreate = "ScreenSettingsSpaceCreate"
    static let createSpace = "CreateSpace"
    static let switchSpace = "SwitchSpace"
    static let clickDeleteSpace = "ClickDeleteSpace"
    static let clickDeleteSpaceWarning = "ClickDeleteSpaceWarning"
    static let deleteSpace = "DeleteSpace"
    static let screenSettingsSpaceIndex = "ScreenSettingsSpaceIndex"
    
    // Hosting
    static let selectNetwork = "SelectNetwork"
    static let uploadNetworkConfiguration = "UploadNetworkConfiguration"
    
    // Gallery
    static let screenGalleryInstall = "ScreenGalleryInstall"
    static let clickGalleryInstall = "ClickGalleryInstall"
    static let clickGalleryInstallSpace = "ClickGalleryInstallSpace"
    static let galleryInstall = "GalleryInstall"
    
    // Spaces
    static let shareSpace = "ShareSpace"
    static let screenSettingsSpaceShare = "ScreenSettingsSpaceShare"
    static let clickShareSpaceCopyLink = "ClickShareSpaceCopyLink"
    static let screenStopShare = "ScreenStopShare"
    static let stopSpaceShare = "StopSpaceShare"
    static let clickSettingsSpaceShare = "ClickSettingsSpaceShare"
    static let screenRevokeShareLink = "ScreenRevokeShareLink"
    static let revokeShareLink = "RevokeShareLink"
    static let screenInviteConfirm = "ScreenInviteConfirm"
    static let approveInviteRequest = "ApproveInviteRequest"
    static let rejectInviteRequest = "RejectInviteRequest"
    static let changeSpaceMemberPermissions = "ChangeSpaceMemberPermissions"
    static let removeSpaceMember = "RemoveSpaceMember"
    static let screenInviteRequest = "ScreenInviteRequest"
    static let screenRequestSent = "ScreenRequestSent"
    static let screenSettingsSpaceList = "ScreenSettingsSpaceList"
    static let screenLeaveSpace = "ScreenLeaveSpace"
    static let leaveSpace = "LeaveSpace"
    static let approveLeaveRequest = "ApproveLeaveRequest"
    
    // Keyboard bar actions
    enum KeyboardBarAction {
        static let slashMenu = "KeyboardBarSlashMenu"
        static let styleMenu = "KeyboardBarStyleMenu"
        static let selectionMenu = "KeyboardBarSelectionMenu"
        static let mentionMenu = "KeyboardBarMentionMenu"
        static let hideKeyboard = "KeyboardBarHideKeyboardMenu"
    }
    
    enum Widget {
        static let edit = "EditWidget"
        static let add = "AddWidget"
        static let delete = "DeleteWidget"
        static let changeSource = "ChangeWidgetSource"
        static let changeLayout = "ChangeWidgetLayout"
        static let reorderWidget = "ReorderWidget"
    }
    
    enum Sidebar {
        static let openGroupToggle = "OpenSidebarGroupToggle"
        static let closeGroupToggle = "CloseSidebarGroupToggle"
    }
    
    enum About {        
        static let whatIsNew = "MenuHelpWhatsNew"
        static let anytypeCommunity = "MenuHelpCommunity"
        static let helpAndTutorials = "MenuHelpTutorial"
        static let contactUs = "MenuHelpContact"

        static let termsOfUse = "MenuHelpTerms"
        static let privacyPolicy = "MenuHelpPrivacy"
        static let acknowledgments = "acknowledgments"
    }
    
    enum FileStorage {
        static let getMoreSpace = "GetMoreSpace"
    }
}

// MARK: - Keychain showing context

enum AnalyticsEventsKeychainContext: String {
    case settings = "ScreenSettings"
    case logout = "BeforeLogout"
    case signup = "FirstSession"
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
    static let step = "step"

    static let type = "type"
    static let id = "id"
    static let objectType = "objectType"
    static let embedType = "embedType"
    static let length = "length"
    static let layout = "layout"
    static let align = "align"
    static let format = "format"
    static let condition = "condition"
    static let linkType = "linkType"
    static let context = "context"
    static let color = "color"
    static let name = "name"
    
    static let middleTime = "middleTime"
}

enum AnalyticsEventsTypeValues {
    static let customType = "Custom"
}

enum AnalyticsEventsRouteKind: String {
    case set = "Set"
    case collection = "Collection"
    case mention = "Mention"
    case powertool = "Powertool"
    case turnInto = "TurnInto"
    case navigation = "Navigation"
    case widget = "Widget"
    case sharingExtension = "SharingExtension"
    case homeScreen = "HomeScreen"
    case clipboard = "Clipboard"
}

enum AnalyticsEventsRelationType: String {
    case menu = "menu"
    case dataview = "dataview"
    case block = "block"
}

enum AnalyticsEventsSetQueryType {
    static let type = "type"
}

enum AnalyticsEventsSetCollectionEmbedType {
    static let object = "object"
}

enum AnalyticsEventsLinkToObjectType: String {
    case object = "Object"
    case collection = "Collection"
}

enum AnalyticsEventsMigrationType: String {
    case complete = "complete"
    case instruсtions = "instruсtions"
    case download = "download"
    case exit = "exit"
}

enum AnalyticsWidgetSource {
    case favorites
    case recent
    case recentOpen
    case sets
    case collections
    case bin
    case object(type: AnalyticsObjectType)
    
    var analyticsId: String {
        switch self {
        case .favorites:
            return "Favorites"
        case .recent:
            return "Recent"
        case .recentOpen:
            return "RecentOpen"
        case .sets:
            return "Sets"
        case .collections:
            return "Collections"
        case .bin:
            return "Bin"
        case .object(let type):
            return type.analyticsId
        }
    }
}

enum AnalyticsObjectType {
    case object(typeId: String)
    case file(fileExt: String)
    case custom
    
    var analyticsId: String {
        switch self {
        case .object(let typeId):
            return typeId
        case .file(let fileExt):
            return fileExt
        case .custom:
            return AnalyticsEventsTypeValues.customType
        }
    }
}

enum AnalyticsWidgetRoute: String {
    case addWidget = "AddWidget"
    case inner = "Inner"
}

enum AnalyticsWidgetContext: String, Hashable {
    case home = "Home"
    case editor = "Editor"
}

enum RemoveCompletelyRoute: String {
    case bin = "Bin"
    case settings = "Settings"
}

enum ShowDeletionWarningRoute: String {
    case bin = "Bin"
    case settings = "Settings"
}

enum ScreenOnboardingStep: String {
    case void = "Void"
    case phrase = "Phrase"
    case soul = "Soul"
    case soulCreating = "SoulCreating"
    case spaceCreating = "SpaceCreating"
}

enum ClickOnboardingButton: String {
    case showAndCopy = "ShowAndCopy"
    case checkLater = "CheckLater"
    case moreInfo = "MoreInfo"
}

enum ClickLoginButton: String {
    case phrase = "Phrase"
    case qr = "Qr"
    case keychain = "Keychain"
}

enum TableBlockType: String {
    case simpleTableBlock = "table"
}

enum AnalyticsDefaultObjectTypeChangeRoute: String {
    case settings = "Settings"
    case set = "Set"
    case collection = "Collection"
    case navigation = "Navigation"
}

enum SelectObjectTypeRoute: String {
    case longTap = "LongTap"
    case navigation = "Navigation"
    case clipboard = "Clipboard"
}

enum OnboardingTooltip: String {
    case selectType = "SelectType"
    case sharingExtension = "SharingExtension"
    case swipeInWidgets = "ObjectCreationWidget"
}

enum ClickDeleteSpaceRoute: String {
    case navigation = "Navigation"
    case settings = "Settings"
}

enum ClickDeleteSpaceWarningType: String {
    case delete = "Delete"
    case cancel = "Cancel"
}

enum DeleteSpaceType: String {
    case `private` = "Private"
}

enum SelectNetworkType: String {
    case anytype = "Anytype"
    case localOnly = "LocalOnly"
    case selfHost = "SelfHost"
}

enum SelectNetworkRoute: String {
    case onboarding = "Onboarding"
}

enum ClickOnboardingTooltipType: String {
    case showShareMenu = "ShareMenu"
    case close = "Close"
}

enum ClickGalleryInstallSpaceType: String {
    case new = "New"
    case existing = "Existing"
}

enum CreateSpaceRoute: String {
    case navigation = "Navigation"
    case gallery = "Gallery"
}

enum ClickSettingsSpaceShareType: String {
    case moreInfo = "MoreInfo"
    case revoke = "Revoke"
}

enum ScreenInviteConfirmRoute: String {
    case notification = "Notification"
    case settings = "Settings"
}

enum PermissionAnalyticsType: String {
    case read = "Read"
    case write = "Write"
}
