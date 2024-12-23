import Foundation
import AnytypeCore
import Combine

public final class RelationKeysStorage: RelationKeysStorageProtocol, Sendable {
    
    private let storage = SynchronizedArray<String>()
    
    public init() {}
    
    // MARK: - RelationKeysStorageProtocol
    
    public var relationKeys: [String] {
        storage.array
    }
    
    public func set(relationKeys: [String]) {
        storage.mutate {
            $0 = relationKeys
        }
    }
    
    public func amend(relationKeys: [String]) {
        storage.mutate { array in
            relationKeys.forEach { relationKey in
                let index = array.firstIndex { $0 == relationKey }
                if let index = index {
                    array[index] = relationKey
                } else {
                    array.append(relationKey)
                }
            }
        }
    }
    
    public func remove(relationKeys: [String]) {
        storage.removeAll {
            relationKeys.contains($0)
        }
    }
    
    public func contains(relationKeys: [String]) -> Bool {
        storage.array.contains { relationKeys.contains($0) }
    }
}
