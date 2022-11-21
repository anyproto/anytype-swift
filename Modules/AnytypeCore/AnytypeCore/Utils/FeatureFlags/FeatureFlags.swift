import Foundation

public final class FeatureFlags {
    
    private static var isRelease: Bool {
        #if RELEASE
        true
        #else
        false
        #endif
    }
    
    public static let features: [FeatureDescription] = [
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .objectPreview,
        .setListView,
        .setViewTypes,
        .setSyncStatus,
        .cursorPosition,
        .hideBottomViewForStyleMenu,
        .setKanbanView,
        .redesignNewButton,
        .linktoObjectFromItself,
        .linkToObjectFromMarkup,
        .showBookmarkInSets,
        .inlineMarkdown,
        .fixColorsForStyleMenu,
        .redesignBookmarkBlock,
        .showSetsInChangeTypeSearchMenu,
        .fixInsetMediaContent
    ]
    
    public static func update(key feature: FeatureDescription, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: feature.title)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
    
    public static func value(for feature: FeatureDescription) -> Bool {
        let defaultValue = isRelease ? feature.defaultValue : feature.debugValue
        return FeatureFlagsStorage.featureFlags[feature.title] ?? defaultValue
    }
}

public extension FeatureFlags {

    static var showAlertOnAssert: Bool {
        value(for: .showAlertOnAssert)
    }

    static var analytics: Bool {
        value(for: .analytics)
    }
    
    static var rainbowViews: Bool {
        value(for: .rainbowViews)
    }

    static var objectPreview: Bool {
        value(for: .objectPreview)
    }
    
    static var setListView: Bool {
        value(for: .setListView)
    }
    
    static var setViewTypes: Bool {
        value(for: .setViewTypes)
    }
    
    static var setSyncStatus: Bool {
        value(for: .setSyncStatus)
    }
    
    static var cursorPosition: Bool {
        value(for: .cursorPosition)
    }
    
    static var hideBottomViewForStyleMenu: Bool {
        value(for: .hideBottomViewForStyleMenu)
    }
    
    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }
    
    static var redesignNewButton: Bool {
        value(for: .redesignNewButton)
    }

    static var linktoObjectFromItself: Bool {
        value(for: .linktoObjectFromItself)
    }
    
    static var linkToObjectFromMarkup: Bool {
        value(for: .linkToObjectFromMarkup)
    }
    
    static var showBookmarkInSets: Bool {
        value(for: .showBookmarkInSets)
    }
    
    static var inlineMarkdown: Bool {
        value(for: .inlineMarkdown)
    }

    static var fixColorsForStyleMenu: Bool {
        value(for: .fixColorsForStyleMenu)
    }

    static var redesignBookmarkBlock: Bool {
        value(for: .redesignBookmarkBlock)
    }
    
    static var showSetsInChangeTypeSearchMenu: Bool {
        value(for: .showSetsInChangeTypeSearchMenu)
    }
    
    static var fixInsetMediaContent: Bool {
        value(for: .fixInsetMediaContent)
    }
}
