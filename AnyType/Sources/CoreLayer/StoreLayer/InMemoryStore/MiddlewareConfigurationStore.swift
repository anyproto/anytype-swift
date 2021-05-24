import Foundation

// MARK: - Protocols
protocol InMemoryStoreStorageHolderProtocol {
    func add<T>(_ entry: T)
    func get<T>(by type: T.Type) -> T?
    
    func clearStorage()
}

class MiddlewareConfigurationStore: InMemoryStoreStorageHolderProtocol {
    static let shared: InMemoryStoreStorageHolderProtocol = MiddlewareConfigurationStore()
    
    private var store = Store()
    
    func clearStorage() {
        store = Store()
    }
    
    func add<T>(_ entry: T) {
        let key = typeName(some: T.self)
        self.store[key] = entry
    }
    
    func get<T>(by type: T.Type) -> T? {
        let key = typeName(some: T.self)
        return self.store[key] as? T
    }
    
    private func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
}

// MARK: - Base Store
extension MiddlewareConfigurationStore {
    class Store {
        private var store: Dictionary<String, Any> = [:]
        subscript (_ key: String) -> Any? {
            get {
                self.store[key]
            }
            set {
                if newValue.isNil {
                    self.store.removeValue(forKey: key)
                }
                else {
                    self.store[key] = newValue
                }
            }
        }
    }
}
