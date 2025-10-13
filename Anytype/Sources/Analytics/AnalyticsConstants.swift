// MARK: - API Key

enum AnalyticsConfiguration {
    static let apiKey = "AmplitudeApiKey"
    static let blockEvent = "Writing"
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
    static let fileExtension = "fileExtension"

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
    static let sort = "sort"
    static let widgetType = "widgetType"
    
    static let middleTime = "middleTime"
    static let permissions = "permissions"
    static let spaceType = "spaceType"
    static let uxType = "uxType"
    
    static let relationKey = "relationKey"
    static let unreadMessageCount = "unreadMessageCount"
    static let hasMention = "hasMention"
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
    case search = "Search"
    case type = "Type"
    case link = "Link"
    case slashMenu = "SlashMenu"
}

enum AnalyticsEventsRelationType: String {
    case menu = "menu"
    case dataview = "dataview"
    case block = "block"
    case type = "type"
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
//    case allObjects
    case pinned
    case recent
    case recentOpen
    case bin
    case chat
    case object(type: AnalyticsObjectType)
    
    var analyticsId: String {
        switch self {
//        case .allObjects:
//            return "AllObjects"
        case .pinned:
            return "Pinned"
        case .recent:
            return "Recent"
        case .recentOpen:
            return "RecentOpen"
        case .bin:
            return "Bin"
        case .chat:
            return "Chat"
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

enum AnalyticsRelationKey {
    case system(key: String)
    case custom
    
    var value: String {
        switch self {
        case .system(let key):
            return key
        case .custom:
            return "custom"
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
    case main = "Main"
    case object = "Object"
    case auto = "Auto"
}

enum RemoveCompletelyRoute: String {
    case bin = "Bin"
    case settings = "Settings"
}

enum LogoutRoute: String {
    case screenDeletion = "ScreenDeletion"
}

enum ShowDeletionWarningRoute: String {
    case bin = "Bin"
    case settings = "Settings"
}

enum ScreenOnboardingStep: String {
    case phrase = "Phrase"
    case soul = "Soul"
    case email = "Email"
    case persona = "Persona"
    case useCase = "UseCase"
}

enum ClickOnboardingStep: String {
    case persona = "Persona"
    case useCase = "UseCase"
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
    case returnToWidgets = "ReturnToWidgets"
    case space = "Space"
    case chats = "Chats"
}

enum ClickDeleteSpaceRoute: String {
    case navigation = "Navigation"
    case settings = "Settings"
}

enum ClickDeleteSpaceWarningType: String {
    case delete = "Delete"
    case cancel = "Cancel"
}

enum SpaceAccessAnalyticsType: String {
    case `private` = "Private"
    case shared = "Shared"
    case personal = "Personal"
    case unrecognized = "Unrecognized"
}

enum SelectNetworkType: String {
    case anytype = "Anytype"
    case localOnly = "LocalOnly"
    case selfHost = "SelfHost"
}

enum SelectNetworkRoute: String {
    case onboarding = "Onboarding"
    case deeplink = "Deeplink"
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
    case qr = "Qr"
    case shareLink = "ShareLink"
}

enum ScreenInviteConfirmRoute: String {
    case notification = "Notification"
    case settings = "Settings"
}

enum PermissionAnalyticsType: String {
    case read = "Reader"
    case write = "Writer"
    case owner = "Owner"
    case noPermissions = "NoPermissions"
    case unrecognized = "Unrecognized"
}

enum ScreenQrAnalyticsType: String {
    case inviteSpace = "InviteSpace"
}

enum ScreenQrRoute: String {
    case inviteLink = "InviteLink"
    case settingsSpace = "SettingsSpace"
    case spaceProfile = "SpaceProfile"
}

enum ClickShareSpaceCopyLinkRoute: String {
    case button = "Button"
    case menu = "Menu"
    case spaceProfile = "SpaceProfile"
    case spaceSettings = "SpaceSettings"
}

enum ScreenInviteRequestType: String {
    case approval = "Approval"
    case withoutApproval = "WithoutApproval"
}

enum ClickShareSpaceNewLinkType: String {
    case editor = "Editor"
    case viewer = "Viewer"
    case manual = "Manual"
}

enum ClickMembershipType: String {
    case moreInfo = "MoreInfo"
    case payByCard = "Stripe"
    case managePayment = "ManagePayment"
    case sumbit = "Submit"
}

enum ClickUpgradePlanTooltipType: String {
    case storage = "storage"
    case members = "members"
    case editors = "editors"
    case sharedSpaces = "sharedSpaces"
    case publish = "publish"
}

enum ClickShareSpaceShareLinkRoute: String {
    case spaceSettings = "SpaceSettings"
    case spaceProfile = "SpaceProfile"
    case membersScreen = "MembersScreen"
}

enum ClickUpgradePlanTooltipRoute: String {
    case spaceSettings = "ScreenSettingsSpaceIndex"
    case spaceSharing = "ScreenSettingsSpaceShare"
    case confirmInvite = "ScreenInviteConfirm"
    case remoteStorage = "ScreenRemoteStorage"
    case publish = "ScreenPublish"
}

enum ChangeObjectTypeRoute: String {
    case featuredRelations = "FeaturedRelations"
    case relationsList = "RelationsList"
}

enum ScreenSearchType: String {
    case empty = "Empty"
    case saved = "Saved"
}

enum SearchInputRoute: String {
    case library = "Library"
}

enum StyleObjectType: String {
    case date = "Date"
    case custom = "Custom"
}

enum ObjectListSortRoute: String {
    case screenDate = "ScreenDate"
}

enum SettingsSpaceMembersRoute: String {
    case settings = "Settings"
    case navigation = "Navigation"
}

enum SettingsSpaceShareRoute: String {
    case settings = "Settings"
    case navigation = "Navigation"
    case chat = "Chat"
}

enum DeleteRelationRoute: String {
    case type = "Type"
    case object = "Object"
}

enum EditTypeRoute: String {
    case object = "Object"
    case type = "Type"
}

enum OpenObjectByLinkType: String {
    case object = "Object"
    case invite = "Invite"
    case notShared = "NotShared"
}

enum OpenObjectByLinkRoute: String {
    case app = "App"
    case web = "Web"
}

enum WidgetCreateType: String {
    case manual = "Manual"
    case auto = "Auto"
}

enum ResetToTypeDefaultRoute: String {
    case object = "Object"
}

enum ChangeMessageNotificationStateRoute: String {
    case spaceSettings = "ScreenSettingsSpaceIndex"
    case vault = "Vault"
}

enum ChatAttachmentType: String {
    case object = "Object"
    case photo = "Photo"
    case file = "File"
    case camera = "Camera"
    case pagesLists = "PagesLists"
}

enum ScreenAllowPushType: String {
    case initial = "Initial"
    case subsequent = "Subsequent"
    case settings = "Settings"
}

enum ClickAllowPushType: String {
    case enableNotifications = "EnableNotifications"
    case settings = "Settings"
}

enum SentMessageType: String {
    case text = "Text"
    case attachment = "Attachment"
    case mixed = "Mixed"
}

enum UploadMediaRoute: String {
    case camera = "Camera"
    case scan = "Scan"
    case filePicker = "FilePicker"
}

enum ScreenSlashMenuRoute: String {
    case slash = "Slash"
    case keyboardBar = "KeyboardBar"
}

enum UndoRedoResultType: String {
    case `true` = "True"
    case `false` = "False"
}

enum ShareObjectOpenPageRoute: String {
    case menu = "Menu"
    case notification = "Notification"
    case mySites = "MySites"
}

enum MediaFileScreenRoute: String {
    case widget = "Widget"
    case chat = "Chat"
}

enum ClickNavBarAddMenuRoute: String {
    case screenObject = "ScreenObject"
    case screenWidget = "ScreenWidget"
    case screenFavorites = "ScreenFavorites"
    case screenRecentEdit = "ScreenRecentEdit"
    case screenRecentOpen = "ScreenRecentOpen"
    case screenBin = "ScreenBin"
    case screenDate = "ScreenDate"
    case screenType = "ScreenType"
}

enum ClickNavBarAddMenuType: String {
    case camera = "Camera"
    case file = "File"
    case photo = "Photo"
}
