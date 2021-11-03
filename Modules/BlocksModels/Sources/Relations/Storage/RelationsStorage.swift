import Foundation
import AnytypeCore

public final class RelationsStorage {
    
    private var storage = SynchronizedArray<Relation>()
    
    public init() {}
    
}

extension RelationsStorage: RelationsStorageProtocol {
    
    public func set(relations: [Relation]) {
        storage = SynchronizedArray<Relation>(array: relations)
    }
    
    public func amend(relations: [Relation]) {
        storage.append(contentsOf: relations)
    }
    
    public func remove(relationKeys: [String]) {
        storage.removeAll {
            relationKeys.contains($0.key)
        }
    }
    
}

