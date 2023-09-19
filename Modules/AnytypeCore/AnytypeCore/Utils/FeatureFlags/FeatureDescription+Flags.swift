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
    
    static let migrationGuide = FeatureDescription(
        title: "Migration guide",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let newCodeLanguages = FeatureDescription(
        title: "New code languages - IOS-987",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.26.0"),
        defaultValue: true
    )
    
    static let newSetSettings = FeatureDescription(
        title: "New Set settings",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.26.0"),
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
}
