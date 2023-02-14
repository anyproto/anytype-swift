import Foundation

public extension FeatureDescription {
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.?.0",
        defaultValue: false,
        debugValue: false
    )
    
    static let homeWidgets = FeatureDescription(
        title: "Home widgets (IOS-731)",
        author: "m@anytype.io",
        releaseVersion: "0.?.0",
        defaultValue: false,
        debugValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.?.0",
        defaultValue: false,
        debugValue: false
    )
    
    static let fixUpdateRelationBlock = FeatureDescription(
        title: "Fix relation block updates (IOS-801)",
        author: "m@anytype.io",
        releaseVersion: "0.22.0",
        defaultValue: false
    )
    
    static let setTypeContextMenu = FeatureDescription(
        title: "Set type context menu (IOS-917)",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.23.0",
        defaultValue: false,
        debugValue: false
    )
    
    static let styleViewFixColor = FeatureDescription(
        title: "Style view - fix color (IOS-234)",
        author: "m@anytype.io",
        releaseVersion: "0.23.0",
        defaultValue: false,
        debugValue: false
    )
    
    // MARK: - Debug
    
    static let rainbowViews = FeatureDescription(
        title: "Paint editor views 🌈",
        author: "debug",
        releaseVersion: "-",
        defaultValue: false,
        debugValue: false
    )
    
    static let showAlertOnAssert = FeatureDescription(
        title: "Show alerts on asserts\n(only in testflight dev)",
        author: "debug",
        releaseVersion: "-",
        defaultValue: true
    )
    
    static let analytics = FeatureDescription(
        title: "Analytics Amplitude (only in development)",
        author: "debug",
        releaseVersion: "-",
        defaultValue: false,
        debugValue: false
    )
    
    static let middlewareLogs = FeatureDescription(
        title: "Show middleware logs in Xcode console",
        author: "debug",
        releaseVersion: "-",
        defaultValue: false,
        debugValue: false
    )
}
