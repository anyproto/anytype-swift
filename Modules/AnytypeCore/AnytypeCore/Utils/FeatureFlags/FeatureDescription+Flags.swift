import Foundation

public extension FeatureDescription {
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.21.0",
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
