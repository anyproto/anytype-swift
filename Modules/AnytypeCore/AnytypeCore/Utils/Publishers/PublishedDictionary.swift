import Foundation
import Combine

public final class PassthroughSubjectDictionary<K, V> where K: Hashable, V: Equatable {
    
    private var dictionary = SynchronizedDictionary<K, AnytypePassthroughSubject<V?>>()

    public init() {}
    
    public subscript(key: K) -> V? {
        get {
            return self.dictionary[key]?.value
        }
        set {
            var published = dictionary[key] ?? AnytypePassthroughSubject(nil)
            published.value = newValue
            dictionary[key] = published
        }
    }
    
    public func publisher(_ key: K) -> AnyPublisher<V?, Never> {
        let published = dictionary[key] ?? AnytypePassthroughSubject<V?>(nil)
        dictionary[key] = published
        return published.publisher
    }
    
    public func removeValue(forKey key: K) {
        dictionary[key]?.value = nil
    }
    
    public func publishAllValues() {
        dictionary.dictionary.values.forEach { $0.sendUpdate() }
    }
    
    public func publishValue(for key: K) {
        guard let value = dictionary[key] else { return }
        value.sendUpdate()
    }
    
    public func removeAll() {
        dictionary.removeAll()
    }
}
