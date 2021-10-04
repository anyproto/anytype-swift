/// User defaults store
public struct UserDefaultsConfig {
    @UserDefault("userId", defaultValue: "")
    public static var usersIdKey: String

    @UserDefault("App.InstalledAtDate", defaultValue: nil)
    public static var installedAtDate: Date?
    
    // MARK: - Feature flags
    @UserDefault("FeatureFlags", defaultValue: [:])
    private static var encodedFeatureFlags: [String: Bool]
    
    static var featureFlags: [Feature: Bool] {
        get {
            Dictionary(uniqueKeysWithValues: encodedFeatureFlags.compactMap { (key, value) in
                guard let feature = Feature(rawValue: key) else {
                    return nil
                }
                
                return (feature, value)
            })
        }
        set {
            encodedFeatureFlags = Dictionary(uniqueKeysWithValues: newValue.map {
                key, value in (key.rawValue, value)
            })
        }
    }
}
