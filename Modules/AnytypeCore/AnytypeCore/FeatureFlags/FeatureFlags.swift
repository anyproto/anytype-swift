public enum Feature: String, Codable {
    case analytics = "Analytics(Amplitude)"
    case showAlertOnAssert = "Show alerts on asserts\n(only in testflight dev)"
}

public final class FeatureFlags {
    public typealias Features = [Feature: Bool]
    
    public static var features: Features {
        UserDefaultsConfig.featureFlags.merging(defaultValues, uniquingKeysWith: { (first, _) in first })
    }
    
    private static let defaultValues: Features = [
        .showAlertOnAssert : true,
        .analytics : false
    ]
    
    public static func update(key: Feature, value: Bool) {
        var updatedFeatures = UserDefaultsConfig.featureFlags
        updatedFeatures.updateValue(value, forKey: key)
        UserDefaultsConfig.featureFlags = updatedFeatures
    }
}

public extension FeatureFlags {
    static var showAlertOnAssert: Bool {
        features[.showAlertOnAssert, default: true]
    }

    static var analytics: Bool {
        features[.analytics, default: false]
    }
}
