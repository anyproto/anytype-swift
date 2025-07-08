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
    
    static let hideWebPayments = FeatureDescription(
        title: "Hide web based payments for memebership tier",
        type: .feature(author: "vova@anytype.io", releaseVersion: "On demand"),
        defaultValue: true
    )
    
    static let homeSpaceLevelChat = FeatureDescription(
        title: "Show Space-Level Chat",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: true,
        releaseAnyAppValue: true
    )
    
    static let pinnedSpaces = FeatureDescription(
        title: "Pinned Spaces",
        type: .feature(author: "vova@anytype.io", releaseVersion: "11"),
        defaultValue: false,
        debugValue: true
    )
    
    static let openMediaFileInPreview = FeatureDescription(
        title: "Open all media files in preview",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "10"),
        defaultValue: true
    )
    
    static let newPlusMenu = FeatureDescription(
        title: "New plus menu",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    static let spaceUxTypes = FeatureDescription(
        title: "Create chat space",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true
    )
    
    
    static let enableStreamSpaceType = FeatureDescription(
        title: "Create stream space",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )

    static let enablePushMessages = FeatureDescription(
        title: "Enable push messages (⚠️ please restart the app after enabling)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11"),
        defaultValue: true
    )
    
    static let aiToolInSet = FeatureDescription(
        title: "Add AI tool in Set / Collection",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "demo"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: false
    )
    
    static let disableColorfulSeedPhrase = FeatureDescription(
        title: "Disable colorful seed phrase",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "10"),
        defaultValue: true
    )
    
    static let binWidgetFromLibrary = FeatureDescription(
        title: "Bin widget from library",
        type: .feature(author: "m@anytype.io", releaseVersion: "10"),
        defaultValue: true
    )
    
    static let anyAppBetaTip = FeatureDescription(
        title: "Show any app beta alert",
        type: .feature(author: "m@anytype.io", releaseVersion: "demo"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
    )
    
    static let guideUseCaseForDataSpace = FeatureDescription(
        title: "Guide usecase for data space",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11?"),
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
    
    static let spaceHubNewTitle = FeatureDescription(
        title: "New title for Space Hub",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
    )
    
    
    static let chatLayoutInsideSpace = FeatureDescription(
        title: "Chat Layout Inside Space",
        type: .feature(author: "m@anytype.io", releaseVersion: "?"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: false,
        debugValue: true
    )
        
    static let chatCounters = FeatureDescription(
        title: "Counters",
        type: .feature(author: "m@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: true,
        releaseAnyAppValue: true,
        debugValue: true
    )
    
    static let joinStream = FeatureDescription(
        title: "Join to stream after login",
        type: .feature(author: "m@anytype.io", releaseVersion: "?"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
    )
    
    static let countersOnSpaceHub = FeatureDescription(
        title: "Counters on Space Hub",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11"),
        releaseAnytypeValue: true,
        releaseAnyAppValue: true,
        debugValue: true
    )
    
    static let simpleSetForTypes = FeatureDescription(
        title: "Simple set for types",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: true,
        debugValue: false
    )
    
    static let doNotWaitCompletionInAnytypePreview = FeatureDescription(
        title: "Do not wait completion in Anytype Preview",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )
    
    static let plusButtonOnWidgets = FeatureDescription(
        title: "Wodgets - add plus button",
        type: .feature(author: "m@anytype.io", releaseVersion: "10"),
        defaultValue: true
    )
    
    static let openWelcomeObject = FeatureDescription(
        title: "Open welcome object",
        type: .feature(author: "m@anytype.io", releaseVersion: "10.5"),
        defaultValue: true
    )
    
    static let spaceLoadingForScreen = FeatureDescription(
        title: "Space Loading State Inside Screen",
        type: .feature(author: "m@anytype.io", releaseVersion: "?"),
        releaseAnytypeValue: false,
        releaseAnyAppValue: false,
        debugValue: false
    )
    
    static let binScreenEmptyAction = FeatureDescription(
        title: "Bin screen - empty action",
        type: .feature(author: "m@anytype.io", releaseVersion: "?"),
        defaultValue: false,
        debugValue: false
    )
    
    static let openFullscreenObjectsFromSetWidget = FeatureDescription(
        title: "Open fullscreen object from set widget",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "11"),
        defaultValue: true
    )
    
    static let chatWidget = FeatureDescription(
        title: "Chat Widget",
        type: .feature(author: "m@anytype.io", releaseVersion: "11.1"),
        defaultValue: true
    )
    
    static let muteSpacePossibility = FeatureDescription(
        title: "Mute space possibility",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "12"),
        defaultValue: true
    )
    
    static let chatLoadingIndicator = FeatureDescription(
        title: "Sync Status for Chat - IOS-4762",
        type: .feature(author: "m@anytype.io", releaseVersion: "12"),
        defaultValue: true
    )
    
    static let anytypeImageCacher = FeatureDescription(
        title: "Anytype - Custom image cacher",
        type: .feature(author: "m@anytype.io", releaseVersion: "12"),
        defaultValue: true
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
    
    // Pulse handles URLSession on main thread.
    // Enable only if you needs to handle session requests.
    static let networkHTTPSRequestsLogger = FeatureDescription(
        title: "Enable network requests logger for images and other https requests",
        type: .debug,
        defaultValue: false,
        debugValue: false
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
        defaultValue: false,
        debugValue: false
    )
}
