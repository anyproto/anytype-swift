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
    
    static let membership = FeatureDescription(
        title: "Membership 💸",
        type: .feature(author: "vova@anytype.io", releaseVersion: "5"),
        defaultValue: false
    )
    
    static let newGlobalSearch = FeatureDescription(
        title: "New global search",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "5"),
        defaultValue: false
    )
    
    static let setEmptyValuesSorting = FeatureDescription(
        title: "Set empty values sorting - IOS-2810",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "5"),
        defaultValue: false
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
        title: "Reset tips 💭 on launch",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let showAllTips = FeatureDescription(
        title: "Show all tips 💭 for testing (ignore rules)",
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
}
