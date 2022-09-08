import BlocksModels
import SwiftUI

struct SetRelation: Identifiable, Equatable, Hashable {
    let relation: Relation
    let option: DataviewRelationOption
    
    var id: String { relation.id }
}

extension Array where Element == DataviewRelationOption {
    #warning("Check")
    func index(of relation: SetRelation) -> Index? {
        firstIndex(where: { $0.key == relation.relation.key })
    }
    
    func index(of relation: DataviewRelationOption) -> Index? {
        firstIndex(where: { $0.key == relation.key })
    }
}
