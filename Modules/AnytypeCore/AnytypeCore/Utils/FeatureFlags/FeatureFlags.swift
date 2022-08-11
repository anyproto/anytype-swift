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
        .middlewareLogs,
        .objectPreview,
        .setFilters,
        .relationDetails,
        .bookmarksFlow,
        .setGalleryView
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
    
    static var middlewareLogs: Bool {
        value(for: .middlewareLogs)
    }

    static var objectPreview: Bool {
        value(for: .objectPreview)
    }
    
    static var isSetFiltersAvailable: Bool {
        value(for: .setFilters)
    }
        
    static var relationDetails: Bool {
        value(for: .relationDetails)
    }
    
    static var bookmarksFlow: Bool {
        value(for: .bookmarksFlow)
    }
    
    static var setGalleryView: Bool {
        value(for: .setGalleryView)
    }
}
