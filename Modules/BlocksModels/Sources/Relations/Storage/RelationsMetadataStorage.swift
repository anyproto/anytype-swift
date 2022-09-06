import Foundation
import AnytypeCore

public final class RelationsMetadataStorage {
    
    private var storage = SynchronizedArray<RelationMetadata>()
    
    public init() {}
    
}

extension RelationsMetadataStorage: RelationsMetadataStorageProtocol {
    
    public var relations: [RelationMetadata] {
        storage.array
    }
    
    public func set(relations: [RelationMetadata]) {
        storage = SynchronizedArray<RelationMetadata>(array: relations)
    }
    
    public func amend(relations: [RelationMetadata]) {
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
