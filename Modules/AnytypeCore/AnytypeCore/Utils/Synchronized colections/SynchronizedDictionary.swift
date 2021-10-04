//
//  SynchronizedDictionary.swift
//  AnytypeCore
//
//  Created by Konstantin Mordan on 25.09.2021.
//

/// A thread-safe dictionary.
public final class SynchronizedDictionary<K, V> where K: Hashable {

    public var dictionary: [K: V] = [:]

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

}
