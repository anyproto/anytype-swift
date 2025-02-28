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
        type: .feature(author: "vova@anytype.io", releaseVersion: "On demand"),
        defaultValue: true
    )
    
    static let allContent = FeatureDescription(
        title: "All content",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false, // improve Global search instead of it
        debugValue: false
    )
    
    static let homeSpaceLevelChat = FeatureDescription(
        title: "Space-Level Chat",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    static let pinnedSpaces = FeatureDescription(
        title: "Pinned Spaces",
        type: .feature(author: "vova@anytype.io", releaseVersion: "10"),
        defaultValue: false,
        debugValue: false
    )
    
    static let newSpacesLoading = FeatureDescription(
        title: "Spaces loading indicator",
        type: .feature(author: "vova@anytype.io", releaseVersion: "10"),
        defaultValue: false,
        debugValue: false
    )
    
    static let primitives = FeatureDescription(
        title: "New Primitives",
        type: .feature(author: "vova@anytype.io", releaseVersion: "10"),
        defaultValue: false,
        debugValue: false
    )
    
    static let memberProfile = FeatureDescription(
        title: "Space member profile",
        type: .feature(author: "vova@anytype.io", releaseVersion: "9"),
        defaultValue: true
    )
    
    static let allContentWidgets = FeatureDescription(
        title: "All content widgets",
        type: .feature(author: "m@anytype.io", releaseVersion: "10"),
        defaultValue: false
    )
    
    static let newTypeIcons = FeatureDescription(
        title: "New type Icons",
        type: .feature(author: "vova@anytype.io", releaseVersion: "10"),
        defaultValue: false,
        debugValue: true
    )
    
    static let openMediaFileInPreview = FeatureDescription(
        title: "Open all media files in preview",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    static let openBookmarkAsLink = FeatureDescription(
        title: "Open bookmark as link",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    static let newSettings = FeatureDescription(
        title: "New settings",
        type: .feature(author: "vova@anytype.io", releaseVersion: "11"),
        defaultValue: false
    )
    
    static let newPlusMenu = FeatureDescription(
        title: "New plus menu",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    static let firebasePushMessages = FeatureDescription(
        title: "Firebase push messages",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11"),
        defaultValue: false,
        debugValue: false
    )
    
    static let newOnboarding = FeatureDescription(
        title: "New onboarding",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    static let disableColorfulSeedPhrase = FeatureDescription(
        title: "Disable colorful seed phrase",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "10"),
        defaultValue: true
    )
    
    static let openTypeAsSet = FeatureDescription(
        title: "Open type in Set View",
        type: .feature(author: "vova@anytype.io", releaseVersion: "10"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
    )
    
    static let anyAppBetaTip = FeatureDescription(
        title: "Show any app beta alert",
        type: .feature(author: "m@anytype.io", releaseVersion: "demo"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
    )
    
    static let disableRestoreLastScreen = FeatureDescription(
        title: "Disable restore last opened screen",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
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
