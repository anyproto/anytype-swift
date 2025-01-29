import Foundation
import AppTarget

public final class FeatureFlags {
    
    public static func update(key feature: FeatureDescription, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: feature.title)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
    
    public static func value(for feature: FeatureDescription) -> Bool {
        let defaultValue = CoreEnvironment.targetType.isDebug ? feature.debugValue : feature.defaultValue
        return FeatureFlagsStorage.featureFlags[feature.title] ?? defaultValue
    }
}
