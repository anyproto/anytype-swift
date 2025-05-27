import Foundation
import os

// Since our property wrapper's Value type isn't optional, but
// can still contain nil values, we'll have to introduce this
// protocol to enable us to cast any assigned value into a type
// that we can compare against nil:
public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional { }

// WARNING: - This storage is not synchronized between processes (because of cache), not suitable for use in extensions
public final class UserDefaultStorage<T: Codable & Sendable>: @unchecked Sendable {
    
    private let key: String
    private let defaultValue: T
    
    private var data: T
    private let lock = OSAllocatedUnfairLock()
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        
        // Read value from UserDefaults
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(T.self, from: data) {
            self.data = value
        } else {
            self.data = defaultValue
        }
    }
    
    public var value: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return data
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            
            data = newValue
            
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                // Convert newValue to data
                let data = try? JSONEncoder().encode(newValue)
                
                // Set value to UserDefaults
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}
