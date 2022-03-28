import BlocksModels
import SwiftUI

struct SetRelation: Identifiable, Equatable {
    let metadata: RelationMetadata
    let option: DataviewRelationOption
    
    var id: String { metadata.id }
}
