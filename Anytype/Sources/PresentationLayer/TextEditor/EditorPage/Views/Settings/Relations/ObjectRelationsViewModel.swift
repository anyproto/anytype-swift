import Foundation
import BlocksModels

final class ObjectRelationsViewModel: ObservableObject {
    
    @Published private(set) var relations: [Relation] = []
    
    func update(with relations: [Relation]) {
        self.relations = relations.filter {
            $0.name.isNotEmpty
        }
    }
    
}
