import Foundation
import AnytypeCore
import Combine

public final class RelationLinksStorage: RelationLinksStorageProtocol {
    
    private var storage = SynchronizedArray<RelationLink>()
    
    public init() {}
    
    // MARK: - RelationLinksStorageProtocol
    
    public var relationLinks: [RelationLink] {
        storage.array
    }
    
    public func set(relationLinks: [RelationLink]) {
        storage = SynchronizedArray<RelationLink>(array: relationLinks)
    }
    
    public func amend(relationLinks: [RelationLink]) {
        storage.mutate { array in
            relationLinks.forEach { relationLink in
                let index = array.firstIndex { $0.key == relationLink.key }
                if let index = index {
                    array[index] = relationLink
                } else {
                    array.append(relationLink)
                }
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
