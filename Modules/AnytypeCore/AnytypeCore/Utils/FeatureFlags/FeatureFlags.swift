import Foundation
import AppTarget

public final class FeatureFlags {
    
    public static func update(key feature: FeatureDescription, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: feature.title)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
    
    public static func value(for feature: FeatureDescription) -> Bool {
        
        let defaultValue: Bool
        
        switch CoreEnvironment.targetType {
        case .debug:
            defaultValue = feature.debugValue
        case .releaseAnyApp:
            defaultValue = feature.releaseAnyAppValue
        case .releaseAnytype:
            defaultValue = feature.releaseAnytypeValue
        }
        
        return FeatureFlagsStorage.featureFlags[feature.title] ?? defaultValue
    }
}
