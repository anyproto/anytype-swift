import Foundation
import Combine

public final class PublishedDictionary<K, V> where K: Hashable {
    
    private var dictionary = SynchronizedDictionary<K, AnytypePublished<V?>>()

    public init() {}
    
    public subscript(key: K) -> V? {
        get {
            return self.dictionary[key]?.value
        }
        set {
            var published = dictionary[key] ?? AnytypePublished(nil)
            published.value = newValue
            dictionary[key] = published
        }
    }
    
    public func publisher(_ key: K) -> AnyPublisher<V?, Never> {
        let published = dictionary[key] ?? AnytypePublished<V?>(nil)
        dictionary[key] = published
        return published.publisher
    }
    
    public func removeValue(forKey key: K) {
        dictionary[key]?.value = nil
    }
}
