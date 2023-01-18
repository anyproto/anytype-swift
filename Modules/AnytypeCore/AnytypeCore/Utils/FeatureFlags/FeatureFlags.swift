import Foundation

public final class FeatureFlags {
    
    private static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    
    public static func update(key feature: FeatureDescription, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: feature.title)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
    
    public static func value(for feature: FeatureDescription) -> Bool {
        let defaultValue = isDebug ? feature.debugValue : feature.defaultValue
        return FeatureFlagsStorage.featureFlags[feature.title] ?? defaultValue
    }
}
