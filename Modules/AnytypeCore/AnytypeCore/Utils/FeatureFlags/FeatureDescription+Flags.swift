import Foundation

public extension FeatureDescription {
    
    static let setTemplateSelection = FeatureDescription(
        title: "Additional button in sets to pick needed template",
        type: .feature(author: "db@anytype.io", releaseVersion: "0.24.0"),
        defaultValue: true
    )
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false
    )
    
    static let newCodeLanguages = FeatureDescription(
        title: "New code languages - IOS-987",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.26.0"),
        defaultValue: true
    )
    
    static let ipadIncreaseWidth = FeatureDescription(
        title: "iPad width",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.26.0"),
        defaultValue: true
    )
    
    static let selectTypeByLongTap = FeatureDescription(
        title: "Object creation flow updates - MVP - IOS-1796",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.26.0"),
        defaultValue: true
    )
    
    
    static let widgetsCreateObject = FeatureDescription(
        title: "Widgets - New object - IOS-1873",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.27.0"),
        defaultValue: true
    )
    
    static let selfHosted = FeatureDescription(
        title: "Widgets - New object - IOS-1873",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.27.0"),
        defaultValue: true
    )

    static let setAndCollectionInSlashMenu = FeatureDescription(
        title: "Set and Collection in slashMenu",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.27.0"),
        defaultValue: true
    )
    
    static let setTextInFirstNoteBlock = FeatureDescription(
        title: "Set text in first Note block when creating from the Set/Collection/Widget - IOS-1956",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.27.0"),
        defaultValue: true
    )
    
    static let bottomNavigationAlwaysBackButton = FeatureDescription(
        title: "[Back] in Bottom menu - IOS-2087",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.27.0"),
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
}
