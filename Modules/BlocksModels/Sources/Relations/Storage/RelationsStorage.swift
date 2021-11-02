import Foundation
import AnytypeCore

public final class RelationsStorage {
    
    private var storage = SynchronizedDictionary<String, Relation>()
    
    public init() {}
    
}

extension RelationsStorage: RelationsStorageProtocol {
    
    public func get(key: String) -> Relation? {
        storage[key]
    }
    
    public func add(relations: Relation, key: String) {
        storage[key] = relations
    }
    
    public func remove(key: String) {
        storage.removeValue(forKey: key)
    }
    
}

