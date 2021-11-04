import BlocksModels
import SwiftProtobuf

struct RelationEntity: Hashable {
    let relation: Relation
    let value: Google_Protobuf_Value?
}

extension RelationEntity: Identifiable {
    
    var id: String {
        relation.id
    }
    
}
