/// A thread-safe dictionary.
import Foundation

public final class SynchronizedDictionary<K, V> where K: Hashable {

    private var dictionary: [K: V] = [:]

    // MARK: - Private variables

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

}
