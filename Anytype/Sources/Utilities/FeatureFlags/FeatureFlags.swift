enum Feature: String, Codable {
    case newHome = "New Home"
    case analytics = "Analytics(Amplitude)"
}

final class FeatureFlags {
    typealias Features = [Feature: Bool]
    
    static var features: Features {
        UserDefaultsConfig.featureFlags.merging(defaultValues, uniquingKeysWith: { (first, _) in first })
    }
    
    private static let defaultValues: Features = [
        .newHome : true,
        .analytics : false
    ]
    
    static func update(key: Feature, value: Bool) {
        var updatedFeatures = UserDefaultsConfig.featureFlags
        updatedFeatures.updateValue(value, forKey: key)
        UserDefaultsConfig.featureFlags = updatedFeatures

        switch key {
        case .analytics:
            Analytics.isEnabled = value
        default:
            return
        }
    }
}

extension FeatureFlags {
    static var newHome: Bool {
        features[.newHome, default: true]
    }

    static var analytics: Bool {
        features[.analytics, default: false]
    }
}
