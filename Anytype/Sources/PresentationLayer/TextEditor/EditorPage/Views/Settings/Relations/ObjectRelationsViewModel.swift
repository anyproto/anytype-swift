import Foundation
import BlocksModels

final class ObjectRelationsViewModel: ObservableObject {
    
    @Published private(set) var relations: [Relation]
    
    init(relations: [Relation] = []) {
        self.relations = relations
    }
    
    func update(with relations: [Relation]) {
        self.relations = relations.filter {
            !$0.isHidden
        }
    }
    
}
