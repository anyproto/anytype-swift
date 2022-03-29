import BlocksModels
import SwiftUI

struct SetRelation: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let option: DataviewRelationOption
    
    var id: String { metadata.id }
}

extension Array where Element == DataviewRelationOption {
    func index(of relation: SetRelation) -> Index? {
        firstIndex(where: { $0.key == relation.id })
    }
    
    func index(of relation: DataviewRelationOption) -> Index? {
        firstIndex(where: { $0.key == relation.key })
    }
}
