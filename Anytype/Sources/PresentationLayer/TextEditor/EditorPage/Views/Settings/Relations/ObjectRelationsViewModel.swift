import Foundation
import BlocksModels

final class ObjectRelationsViewModel: ObservableObject {
    
    @Published private(set) var relationEntities: [RelationEntity]
    
    init(relationEntities: [RelationEntity] = []) {
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
