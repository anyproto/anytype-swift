import BlocksModels
import SwiftUI

struct SetRelation: Identifiable {
    let isVisible: Bool
    let metadata: RelationMetadata
    let relation: DataviewRelation
    
    var id: String { metadata.id }
}
