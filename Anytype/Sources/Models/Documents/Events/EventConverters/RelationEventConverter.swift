import Foundation
import Services

final class RelationEventConverter {
    
    private let relationLinksStorage: RelationLinksStorageProtocol
    
    init(
        relationLinksStorage: RelationLinksStorageProtocol
    ) {
        self.relationLinksStorage = relationLinksStorage
    }
    
    func convert(_ event: RelationEvent) -> DocumentUpdate? {
        switch event {
        case let .relationChanged(relationKeys):
            let contains = relationLinksStorage.relationLinks.contains { relationKeys.contains($0.key) }
            return contains ? .general : .none
        }
    }
}
