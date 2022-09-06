import Foundation
import BlocksModels

final class RelationEventConverter {
    
    private let relationLinksStorage: RelationLinksStorageProtocol
    
    init(
        relationLinksStorage: RelationLinksStorageProtocol
    ) {
        self.relationLinksStorage = relationLinksStorage
    }
    
    func convert(_ event: RelationEvent) -> DocumentUpdate? {
        switch event {
        case let .relationChanged(relationIds):
            let contains = relationLinksStorage.relationLinks.contains { relationIds.contains($0.id) }
            return contains ? .general : .none
        }
    }
}
