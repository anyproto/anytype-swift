import Foundation

extension FeatureDescription {
    
    static let objectPreview = FeatureDescription(
        title: "Object preview",
        author: "k@anytype.io",
        releaseVersion: "-",
        defaultValue: false,
        debugValue: false
    )
    
    static let setFilters = FeatureDescription(
        title: "Set filters",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.17.0",
        defaultValue: true
    )
    
    static let relationDetails = FeatureDescription(
        title: "Relation details in read only mode",
        author: "m@anytype.io",
        releaseVersion: "0.17.0",
        defaultValue: true
    )
    
    static let bookmarksFlow = FeatureDescription(
        title: "New bookmarks flow",
        author: "m@anytype.io",
        releaseVersion: "0.17.0",
        defaultValue: true
    )
    
    static let bookmarksFlowP2 = FeatureDescription(
        title: "New bookmarks flow part 2",
        author: "m@anytype.io",
        releaseVersion: "0.18.0",
        defaultValue: false
    )
    
    static let setGalleryView = FeatureDescription(
        title: "Set gallery view",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.17.0",
        defaultValue: true
    )
    
    static let setListView = FeatureDescription(
        title: "Set list view",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.18.0",
        defaultValue: false
    )
    
    static let setViewTypes = FeatureDescription(
        title: "Set view types",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.18.0",
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
