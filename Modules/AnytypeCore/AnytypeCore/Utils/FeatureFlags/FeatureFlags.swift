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
        .linktoObjectFromItself
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
    
    static var linktoObjectFromItself: Bool {
        value(for: .linktoObjectFromItself)
    }
}
