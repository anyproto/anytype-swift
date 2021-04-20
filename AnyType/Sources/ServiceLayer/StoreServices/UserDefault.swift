import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

/// User defaults store
struct UserDefaultsConfig {
    @UserDefault("userId", defaultValue: "")
    static var usersIdKey: String
    
    @UserDefault("userName", defaultValue: "")
    static var userName: String//Dictionary<String, String>
    
    @UserDefault("notificationUpdates", defaultValue: false)
    static var notificationUpdates: Bool
    
    @UserDefault("notificationNewInvites", defaultValue: false)
    static var notificationNewInvites: Bool
    
    @UserDefault("notificationNewComments", defaultValue: false)
    static var notificationNewComments: Bool
    
    @UserDefault("notificationNewDevice", defaultValue: false)
    static var notificationNewDevice: Bool
}

// Services handling
extension UserDefaultsConfig {
    @UserDefault("App.InstalledAtDate", defaultValue: nil)
    static var installedAtDate: Date?
}

// Feature flags
extension UserDefaultsConfig {
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
