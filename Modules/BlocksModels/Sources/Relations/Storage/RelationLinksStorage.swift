import Foundation
import AnytypeCore

public final class RelationLinksStorage: RelationLinksStorageProtocol {
    
    private var storage = SynchronizedArray<RelationLink>()
    
    public init() {}
    
    public var relationLinks: [RelationLink] {
        storage.array
    }
    
    public func set(relationLinks: [RelationLink]) {
        storage = SynchronizedArray<RelationLink>(array: relationLinks)
    }
    
    public func amend(relationLinks: [RelationLink]) {
        relationLinks.forEach { relationLink in
            let index = storage.array.firstIndex { $0.key == relationLink.key }
            if let index = index {
                storage[index] = relationLink
            } else {
                storage.append(relationLink)
            }
        }
    }
    
    public func remove(relationKeys: [String]) {
        storage.removeAll {
            relationKeys.contains($0.key)
        }
    }
    
    public func contains(relationKeys: [String]) -> Bool {
        storage.array.contains { relationKeys.contains($0.key) }
    }
}
