import Foundation
import Combine

@propertyWrapper
public struct UserDefault<T: Codable & Sendable>: Sendable {
    private let storage: UserDefaultStorage<T>

    public init(_ key: String, defaultValue: T) {
        self.storage = UserDefaultStorage(key: key, defaultValue: defaultValue)
    }

    public var wrappedValue: T {
        get { storage.value }
        set { storage.value = newValue }
    }
}

@propertyWrapper
public struct UserDefaultByAppGroup<T: Codable & Sendable>: Sendable {
    private let storage: UserDefaultByAppGroupStorage<T>

    public init(_ key: String, defaultValue: T) {
        self.storage = UserDefaultByAppGroupStorage(key: key, defaultValue: defaultValue)
    }

    public var wrappedValue: T {
        get { storage.value }
        set { storage.value = newValue }
    }
}
