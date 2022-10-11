import Foundation

extension FeatureDescription {
    
    static let objectPreview = FeatureDescription(
        title: "Object preview",
        author: "k@anytype.io",
        releaseVersion: "-",
        defaultValue: false,
        debugValue: false
    )
    
    static let setListView = FeatureDescription(
        title: "Set list view",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.18.0",
        defaultValue: true
    )
    
    static let setViewTypes = FeatureDescription(
        title: "Set view types",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.18.0",
        defaultValue: true
    )
    
    static let setSyncStatus = FeatureDescription(
        title: "Set sync status",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.19.0",
        defaultValue: false
    )
    
    static let cursorPosition = FeatureDescription(
        title: "Cursor position after change style",
        author: "m@anytype.io",
        releaseVersion: "0.19.0",
        defaultValue: false
    )
    
    static let hideBottomViewForStyleMenu = FeatureDescription(
        title: "Hide bottom navigation view in editor for style menu (IOS-293)",
        author: "m@anytype.io",
        releaseVersion: "0.19.0",
        defaultValue: false
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
