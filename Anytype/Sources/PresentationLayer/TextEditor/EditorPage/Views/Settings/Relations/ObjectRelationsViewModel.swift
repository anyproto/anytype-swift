import Foundation
import BlocksModels

final class ObjectRelationsViewModel: ObservableObject {
    
    @Published private(set) var relations: [RelationEntity]
    
    init(relations: [RelationEntity] = []) {
        self.relations = relations
    }
    
    func update(with relations: [Relation], details: ObjectDetails) {
        let visibleRelations = relations.filter { !$0.isHidden }
        
        self.relations = visibleRelations.map {
            RelationEntity(
                relation: $0,
                value: details.values[$0.key]
            )
        }
    }
    
}
