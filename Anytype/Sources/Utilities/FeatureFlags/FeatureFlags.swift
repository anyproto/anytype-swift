enum Feature: String, Codable {
    case newHome = "New Home"
}

final class FeatureFlags {
    typealias Features = [Feature: Bool]
    
    static var features: Features {
        UserDefaultsConfig.featureFlags.merging(defaultValues, uniquingKeysWith: { (first, _) in first })
    }
    
    private static let defaultValues: Features = [
        .newHome : true
    ]
    
    static func update(key: Feature, value: Bool) {
        var updatedFeatures = UserDefaultsConfig.featureFlags
        updatedFeatures.updateValue(value, forKey: key)
        UserDefaultsConfig.featureFlags = updatedFeatures
    }
}

extension FeatureFlags {
    static var newHome: Bool {
        features[.newHome, default: true]
    }
}
