import Foundation
import BlocksModels

final class ObjectRelationsViewModel: ObservableObject {
    
    let detailsStorage: ObjectDetailsStorageProtocol
    @Published private(set) var relationEntities: [RelationEntity]
    
    init(
        detailsStorage: ObjectDetailsStorageProtocol,
        relationEntities: [RelationEntity] = []
    ) {
        self.detailsStorage = detailsStorage
        self.relationEntities = relationEntities
    }
    
    func update(with relations: [Relation], details: ObjectDetails) {
        let visibleRelations = relations.filter { !$0.isHidden }
        
        self.relationEntities = visibleRelations.map {
            RelationEntity(
                relation: $0,
                value: details.values[$0.key]
            )
        }
    }
    
}
