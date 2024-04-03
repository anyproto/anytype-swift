/// A thread-safe dictionary.
import Foundation

public final class SynchronizedDictionary<K, V> where K: Hashable {

    // MARK: - Private variables
    
    private var dictionary: [K: V] = [:]
    private let lock = NSLock()

    // MARK: - Initializers

    public init() {}

    // MARK: - Public functions

    public subscript(key: K) -> V? {
        get {
            var value: V?

            lock.lock()
            value = self.dictionary[key]
            lock.unlock()

            return value
        }
        set {
            lock.lock()
            dictionary[key] = newValue
            lock.unlock()
        }
    }
    
    public func removeValue(forKey key: K) {
        lock.lock()
        dictionary.removeValue(forKey: key)
        lock.unlock()
    }
    
    public var keys: Dictionary<K, V>.Keys {
        lock.lock()
        let keys = dictionary.keys
        lock.unlock()
        
        return keys
    }
    
    public var values: Dictionary<K, V>.Values {
        lock.lock()
        let values = dictionary.values
        lock.unlock()
        
        return values
    }
    
    public func removeAll() {
        lock.lock()
        dictionary.removeAll()
        lock.unlock()
    }
    
    public func dictionary<T>(using lockDictionary: (Dictionary<K, V>) -> T) -> T {
        lock.lock()
        let generic = lockDictionary(dictionary)
        lock.unlock()
        
        return generic
    }
}
