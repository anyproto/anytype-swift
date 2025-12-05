import Foundation

// Call `make generate` to update FeatureFlags helper

public extension FeatureDescription {

    // should be disabled
    static let channelTypeSwitcher = FeatureDescription(
        title: "Channel type switcher - IOS-5378",
        type: .feature(author: "vova@anytype.io", releaseVersion: "14"),
        defaultValue: false
    )

    static let showUploadStatusIndicator = FeatureDescription(
        title: "Show visual indicator for uploading files - IOS-5054",
        type: .feature(author: "vova@anytype.io", releaseVersion: "14"),
        defaultValue: false
    )
    
    static let newObjectSettings = FeatureDescription(
        title: "New Object Settings",
        type: .feature(author: "vova@anytype.io", releaseVersion: "15"),
        defaultValue: false,
        debugValue: true
    )
    
    static let oneToOneSpaces = FeatureDescription(
        title: "1-1 Spaces - IOS-5531",
        type: .feature(author: "vova@anytype.io", releaseVersion: "15"),
        defaultValue: false,
        debugValue: true
    )

    static let chatSettings = FeatureDescription(
        title: "Chat Settings",
        type: .feature(author: "vova@anytype.io", releaseVersion: "15"),
        defaultValue: false,
        debugValue: true
    )

    static let qrCodeCircularText = FeatureDescription(
        title: "QR Code Circular Text - IOS-5580",
        type: .feature(author: "vova@anytype.io", releaseVersion: "16"),
        defaultValue: false,
        debugValue: true
    )

    // MARK: - Experemental
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false
    )

    // MARK: - Debug
    
    static let rainbowViews = FeatureDescription(
        title: "Paint editor views 🌈",
        type: .debug,
        defaultValue: false
    )
    
    static let showAlertOnAssert = FeatureDescription(
        title: "Show alerts on asserts\n(only for test builds)",
        type: .debug,
        defaultValue: true
    )
    
    static let analytics = FeatureDescription(
        title: "Analytics - send events to Amplitude (only for test builds)",
        type: .debug,
        defaultValue: false
    )
    
    static let analyticsAlerts = FeatureDescription(
        title: "Analytics - show alerts",
        type: .debug,
        defaultValue: false
    )
    
    static let nonfatalAlerts = FeatureDescription(
        title: "Show non fatal alerts",
        type: .debug,
        defaultValue: false,
        debugValue: CoreEnvironment.isSimulator
    )
    
    static let resetTips = FeatureDescription(
        title: "Tips 💭 - reset on launch",
        type: .debug,
        defaultValue: false
    )
    
    static let showAllTips = FeatureDescription(
        title: "Tips 💭 - show immediate (ignore time rules)",
        type: .debug,
        defaultValue: false
    )
    
    static let sharingExtensionShowContentTypes = FeatureDescription(
        title: "Sharing extension - Show content types",
        type: .debug,
        defaultValue: false,
        debugValue: true
    )
    
    static let membershipTestTiers = FeatureDescription(
        title: "Show test Membership tiers 💸",
        type: .debug,
        defaultValue: false,
        debugValue: true
    )
    
    static let failReceiptValidation = FeatureDescription(
        title: "Fail receipt validaton of Memebership",
        type: .debug,
        defaultValue: false
    )
    
    static let showGlobalSearchScore = FeatureDescription(
        title: "Show global search score",
        type: .debug,
        defaultValue: false
    )
    
    // Pulse handles URLSession on main thread.
    // Enable only if you needs to handle session requests.
    static let networkHTTPSRequestsLogger = FeatureDescription(
        title: "Enable network requests logger for images and other https requests",
        type: .debug,
        defaultValue: false
    )
    
    static let logMiddlewareRequests = FeatureDescription(
        title: "Log middleware requests",
        type: .debug,
        defaultValue: false,
        debugValue: true
    )
    
    static let showPushMessagesInForeground = FeatureDescription(
        title: "Show push messages in foreground",
        type: .debug,
        defaultValue: false
    )
    
    static let skipOnboardingEmailCollection = FeatureDescription(
        title: "Skip mandatory onboarding email collection",
        type: .debug,
        defaultValue: false,
        debugValue: true
    )
    static let spaceHubAlwaysShowLoading = FeatureDescription(
        title: "Space Hub - Always show loading",
        type: .debug,
        defaultValue: false
    )

    static let showHangedObjects = FeatureDescription(
        title: "Show hanged objects",
        type: .debug,
        defaultValue: false
    )
}
