import BlocksModels
import SwiftUI

struct SetRelation: Identifiable {
    let isVisible: Bool
    let metadata: RelationMetadata
    
    var id: String { metadata.id }
}
