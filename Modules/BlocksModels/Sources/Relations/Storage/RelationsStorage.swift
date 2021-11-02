import Foundation
import AnytypeCore

public final class RelationsStorage {
    
    private var storage = SynchronizedDictionary<String, Relation>()
    
    public init() {}
    
}

extension RelationsStorage: RelationsStorageProtocol {
    
    public func get(id: String) -> Relation? {
        storage[id]
    }
    
    public func add(details: Relation, id: String) {
        storage[id] = details
    }
    
}

