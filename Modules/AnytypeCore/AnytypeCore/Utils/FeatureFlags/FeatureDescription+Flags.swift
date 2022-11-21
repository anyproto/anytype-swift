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
        defaultValue: true
    )
    
    static let cursorPosition = FeatureDescription(
        title: "Cursor position after change style",
        author: "m@anytype.io",
        releaseVersion: "0.19.0",
        defaultValue: true
    )
    
    static let hideBottomViewForStyleMenu = FeatureDescription(
        title: "Hide bottom navigation view in editor for style menu (IOS-293)",
        author: "m@anytype.io",
        releaseVersion: "0.19.0",
        defaultValue: true
    )
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        author: "joe_pusya@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false,
        debugValue: false
    )

    static let redesignNewButton = FeatureDescription(
        title: "Set redesign \"new\" button",
        author: "m@anytype.io",
        releaseVersion: "0.19.0",
        defaultValue: true
    )

    static let linktoObjectFromItself = FeatureDescription(
        title: "Link to object from itself",
        author: "db@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )
    
    static let linkToObjectFromMarkup = FeatureDescription(
        title: "Link to object from markup",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )
    
    static let showBookmarkInSets = FeatureDescription(
        title: "Show bookmark type in sets (IOS-538)",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )
    
    static let inlineMarkdown = FeatureDescription(
        title: "Inline markdown (IOS-78)",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )

    static let fixColorsForStyleMenu = FeatureDescription(
        title: "Fix colors for style menu (IOS-94)",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )

    static let redesignBookmarkBlock = FeatureDescription(
        title: "Redesign bookmark block (ios-527)",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )
    
    static let showSetsInChangeTypeSearchMenu = FeatureDescription(
        title: "Show sets in change type search menu (IOS-664)",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
        defaultValue: false
    )
    
    static let fixInsetMediaContent = FeatureDescription(
        title: "Fix insert media content (IOS-552)",
        author: "m@anytype.io",
        releaseVersion: "0.20.0",
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
