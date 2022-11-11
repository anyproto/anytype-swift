import Foundation
import AnytypeCore
import Combine

public final class RelationLinksStorage: RelationLinksStorageProtocol {
    
    @Published private var storage = [RelationLink]()
    
    public init() {}
    
    // MARK: - RelationLinksStorageProtocol
    
    public var relationLinks: [RelationLink] {
        storage
    }

    public var relationLinksPublisher: AnyPublisher<[RelationLink], Never> {
        $storage.eraseToAnyPublisher()
    }
    
    public func set(relationLinks: [RelationLink]) {
        storage = relationLinks
    }
    
    public func amend(relationLinks: [RelationLink]) {
        relationLinks.forEach { relationLink in
            let index = storage.firstIndex { $0.key == relationLink.key }
            if let index = index {
                storage[index] = relationLink
            } else {
                storage.append(relationLink)
            }
        }
    }
    
    public func remove(relationIds: [String]) {
        storage.removeAll {
            relationIds.contains($0.key)
        }
    }
    
    public func contains(relationKeys: [String]) -> Bool {
        storage.contains { relationKeys.contains($0.key) }
    }
}
