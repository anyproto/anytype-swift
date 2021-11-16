import Foundation
import AnytypeCore

public final class RelationsStorage {
    
    private var storage = SynchronizedArray<Relation>()
    
    public init() {}
    
}

extension RelationsStorage: RelationsStorageProtocol {
    
    public var relations: [Relation] {
        storage.array
    }
    
    public func set(relations: [Relation]) {
        storage = SynchronizedArray<Relation>(array: relations)
    }
    
    public func amend(relations: [Relation]) {
        relations.forEach { relation in
            let index = storage.array.firstIndex { $0.id == relation.id }
            if let index = index {
                storage[index] = relation
            } else {
                storage.append(relation)
            }
        }
    }
    
    public func remove(relationKeys: [String]) {
        storage.removeAll {
            relationKeys.contains($0.key)
        }
    }
    
}
