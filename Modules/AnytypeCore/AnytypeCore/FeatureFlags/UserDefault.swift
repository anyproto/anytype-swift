import Foundation
import Combine

@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

/// User defaults store
public struct UserDefaultsConfig {
    @UserDefault("userId", defaultValue: "")
    public static var usersIdKey: String
}

// Services handling
public extension UserDefaultsConfig {
    @UserDefault("App.InstalledAtDate", defaultValue: nil)
    static var installedAtDate: Date?
}

// Feature flags
public extension UserDefaultsConfig {
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
