import Foundation

public extension FeatureDescription {
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let homeWidgets = FeatureDescription(
        title: "Home widgets (IOS-731)",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let fixUpdateRelationBlock = FeatureDescription(
        title: "Fix relation block updates (IOS-801)",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let styleViewFixColor = FeatureDescription(
        title: "Style view - fix color (IOS-234)",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: false
    )
    
    static let migrationGuide = FeatureDescription(
        title: "Migration guide",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let keyboardToolbarInSets = FeatureDescription(
        title: "Keyboard toolbar (Done button) in Set/Collection",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let fileStorage = FeatureDescription(
        title: "File storage",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let newAuthorization = FeatureDescription(
        title: "New authorization",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
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
}
