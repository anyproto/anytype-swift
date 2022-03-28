import BlocksModels
import SwiftUI

struct SetRelation: Identifiable {
    let metadata: RelationMetadata
    let option: DataviewRelationOption
    
    var id: String { metadata.id }
}
