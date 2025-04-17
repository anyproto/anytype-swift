import Services
import SwiftUI

struct SetRelation: Identifiable, Hashable {
    let relationDetails: RelationDetails
    let option: DataviewRelationOption
    
    var id: String { relationDetails.id }
}

extension Array where Element == DataviewRelationOption {
    func index(of relation: SetRelation) -> Index? {
        firstIndex(where: { $0.key == relation.relationDetails.key })
    }
    
    func index(of relation: DataviewRelationOption) -> Index? {
        firstIndex(where: { $0.key == relation.key })
    }
}
