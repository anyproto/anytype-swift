import Foundation

// Call `make generate` to update FeatureFlags helper

public extension FeatureDescription {
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false
    )
    
    static let hideCoCreator = FeatureDescription(
        title: "Hide CoCreator tier",
        type: .feature(author: "vova@anytype.io", releaseVersion: "4.5"),
        defaultValue: true
    )
    
    static let versionHistory = FeatureDescription(
        title: "Version History - IOS-3058",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "7"),
        defaultValue: true
    )
    
    static let allContent = FeatureDescription(
        title: "All content",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "7"),
        defaultValue: true
    )
    
    static let spaceHubParallax = FeatureDescription(
        title: "Parallax on Space hub screen",
        type: .feature(author: "vova@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )
    
    static let userWarningAlerts = FeatureDescription(
        title: "User warning alerts",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "7"),
        defaultValue: true
    )
    
    static let dateAsAnObject = FeatureDescription(
        title: "Date as an object",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "8"),
        defaultValue: true
    )
    
    static let homeSpaceLevelChat = FeatureDescription(
        title: "Space-Level Chat",
        type: .feature(author: "m@anytype.io", releaseVersion: "9"),
        defaultValue: false,
        debugValue: false
    )
    
    static let showBinWidgetIfNotEmpty = FeatureDescription(
        title: "Show Bin on home screen if it is not empty",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "7.1"),
        defaultValue: true
    )
    
    static let primitives = FeatureDescription(
        title: "Types, relations, layouts overhaul",
        type: .feature(author: "vova@anytype.io", releaseVersion: "8"),
        defaultValue: false,
        debugValue: true
    )
    
    // MARK: - Debug
    
    static let rainbowViews = FeatureDescription(
        title: "Paint editor views 🌈",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let showAlertOnAssert = FeatureDescription(
        title: "Show alerts on asserts\n(only for test builds)",
        type: .debug,
        defaultValue: true
    )
    
    static let analytics = FeatureDescription(
        title: "Analytics - send events to Amplitude (only for test builds)",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let analyticsAlerts = FeatureDescription(
        title: "Analytics - show alerts",
        type: .debug,
        defaultValue: false,
        debugValue: false
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
        defaultValue: false,
        debugValue: false
    )
    
    static let showAllTips = FeatureDescription(
        title: "Tips 💭 - show immediate (ignore time rules)",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let sharingExtensionShowContentTypes = FeatureDescription(
        title: "Sharing extension - Show content types",
        type: .debug,
        defaultValue: false,
        debugValue: true
    )
    
    static let homeTestSwipeGeature = FeatureDescription(
        title: "Test swipe gesture",
        type: .debug,
        defaultValue: false
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
        defaultValue: false,
        debugValue: false
    )
    
    static let showGlobalSearchScore = FeatureDescription(
        title: "Show global search score",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let versionHistoryPaginationTest = FeatureDescription(
        title: "Version history pagination test - 15",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
}
