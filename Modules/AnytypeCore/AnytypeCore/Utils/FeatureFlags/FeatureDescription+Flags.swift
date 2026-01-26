import Foundation

// Call `make generate` to update FeatureFlags helper

public extension FeatureDescription {

    static let homePage = FeatureDescription(
        title: "Home Page",
        category: .productFeature(author: "vova@anytype.io", targetRelease: "17"),
        defaultValue: false
    )

    static let qrCodeCircularText = FeatureDescription(
        title: "QR Code Circular Text - IOS-5580",
        category: .productFeature(author: "vova@anytype.io", targetRelease: "17"),
        defaultValue: false,
        debugValue: true
    )
    
    // should be disabled
    static let channelTypeSwitcher = FeatureDescription(
        title: "Channel type switcher - IOS-5378",
        category: .productFeature(author: "vova@anytype.io", targetRelease: "17"),
        defaultValue: false
    )
    
    static let showUploadStatusIndicator = FeatureDescription(
        title: "Show visual indicator for uploading files - IOS-5054",
        category: .productFeature(author: "vova@anytype.io", targetRelease: "17"),
        defaultValue: true
    )

    // MARK: - Experemental
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        category: .productFeature(author: "joe_pusya@anytype.io", targetRelease: "?"),
        defaultValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        category: .productFeature(author: "joe_pusya@anytype.io", targetRelease: "?"),
        defaultValue: false
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        category: .productFeature(author: "joe_pusya@anytype.io", targetRelease: "?"),
        defaultValue: false
    )
    
    static let matchedTransitionSource = FeatureDescription(
        title: "iOS 26 - matchedTransitionSource (source view may disappear)",
        category: .productFeature(author: "vova@anytype.io", targetRelease: "?"),
        defaultValue: false
    )

    // MARK: - Debug
    
    static let rainbowViews = FeatureDescription(
        title: "Paint editor views 🌈",
        category: .developerTool,
        defaultValue: false
    )
    
    static let showAlertOnAssert = FeatureDescription(
        title: "Show alerts on asserts\n(only for test builds)",
        category: .developerTool,
        defaultValue: true
    )
    
    static let analytics = FeatureDescription(
        title: "Analytics - send events to Amplitude (only for test builds)",
        category: .developerTool,
        defaultValue: false
    )
    
    static let analyticsAlerts = FeatureDescription(
        title: "Analytics - show alerts",
        category: .developerTool,
        defaultValue: false
    )
    
    static let nonfatalAlerts = FeatureDescription(
        title: "Show non fatal alerts",
        category: .developerTool,
        defaultValue: false,
        debugValue: CoreEnvironment.isSimulator
    )
    
    static let resetTips = FeatureDescription(
        title: "Tips 💭 - reset on launch",
        category: .developerTool,
        defaultValue: false
    )
    
    static let showAllTips = FeatureDescription(
        title: "Tips 💭 - show immediate (ignore time rules)",
        category: .developerTool,
        defaultValue: false
    )
    
    static let sharingExtensionShowContentTypes = FeatureDescription(
        title: "Sharing extension - Show content types",
        category: .developerTool,
        defaultValue: false,
        debugValue: true
    )
    
    static let membershipTestTiers = FeatureDescription(
        title: "Show test Membership tiers 💸",
        category: .developerTool,
        defaultValue: false,
        debugValue: true
    )
    
    static let failReceiptValidation = FeatureDescription(
        title: "Fail receipt validaton of Memebership",
        category: .developerTool,
        defaultValue: false
    )
    
    static let showGlobalSearchScore = FeatureDescription(
        title: "Show global search score",
        category: .developerTool,
        defaultValue: false
    )
    
    // Pulse handles URLSession on main thread.
    // Enable only if you needs to handle session requests.
    static let networkHTTPSRequestsLogger = FeatureDescription(
        title: "Enable network requests logger for images and other https requests",
        category: .developerTool,
        defaultValue: false
    )
    
    static let logMiddlewareRequests = FeatureDescription(
        title: "Log middleware requests",
        category: .developerTool,
        defaultValue: false,
        debugValue: true
    )
    
    static let showPushMessagesInForeground = FeatureDescription(
        title: "Show push messages in foreground",
        category: .developerTool,
        defaultValue: false
    )
    
    static let spaceHubAlwaysShowLoading = FeatureDescription(
        title: "Space Hub - Always show loading",
        category: .developerTool,
        defaultValue: false
    )

    static let showHangedObjects = FeatureDescription(
        title: "Show hanged objects",
        category: .developerTool,
        defaultValue: false
    )
}
