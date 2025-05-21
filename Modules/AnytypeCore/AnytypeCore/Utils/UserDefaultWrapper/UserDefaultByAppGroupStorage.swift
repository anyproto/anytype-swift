import Foundation

public final class UserDefaultByAppGroupStorage<T: Codable & Sendable>: @unchecked Sendable {
    
    private let key: String
    private let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var value: T {
        get {
            // Read value from UserDefaults
            guard let data = userDefaultsObject(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }

            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {            
            if let optional = newValue as? AnyOptional, optional.isNil {
                userDefaultsRemoveObject(forKey: key)
            } else {
                // Convert newValue to data
                let data = try? JSONEncoder().encode(newValue)
                
                // Set value to UserDefaults
                userDefaultsSet(data, forKey: key)
            }
        }
    }
    
    // MARK: - UserDefaults.standard migration to UserDefaults with group
        
    private let groupUserDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    private let standardUserDefaults = UserDefaults.standard
    
    private func userDefaultsObject(forKey defaultName: String) -> Any? {
        if let object = groupUserDefaults?.object(forKey: defaultName) {
            return object
        } else {
            let object = standardUserDefaults.object(forKey: defaultName)
            groupUserDefaults?.set(object, forKey: defaultName)
            return object
        }
    }
    
    private func userDefaultsRemoveObject(forKey defaultName: String) {
        groupUserDefaults?.removeObject(forKey: defaultName)
        standardUserDefaults.removeObject(forKey: defaultName)
    }
    
    private func userDefaultsSet(_ value: Any?, forKey defaultName: String) {
        groupUserDefaults?.set(value, forKey: defaultName)
        standardUserDefaults.set(value, forKey: defaultName)
    }
}
