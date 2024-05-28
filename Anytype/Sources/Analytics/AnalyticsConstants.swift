// MARK: - API Key

enum AnalyticsConfiguration {
    static let apiKey = "AmplitudeApiKey"
    static let blockEvent = "Writing"
}

// MARK: - Events name

enum AnalyticsEventsName {    
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
    
    static let middleTime = "middleTime"
    static let permissions = "permissions"
    static let spaceType = "spaceType"
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

enum LogoutRoute: String {
    case screenDeletion = "ScreenDeletion"
}

enum ShowDeletionWarningRoute: String {
    case bin = "Bin"
    case settings = "Settings"
}

enum ScreenOnboardingStep: String {
    case void = "Void"
    case phrase = "Phrase"
    case offline = "Offline"
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
    case spaceShare = "SpaceShare"
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

enum ClickMembershipType: String {
    case moreInfo = "MoreInfo"
    case payByCard = "Stripe"
    case managePayment = "ManagePayment"
}
