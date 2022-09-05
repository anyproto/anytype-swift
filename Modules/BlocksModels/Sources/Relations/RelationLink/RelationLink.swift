import Foundation
import ProtobufMessages

public struct RelationLink {
    public let id: String
    public let key: String
}

public extension RelationLink {
    
    init(middlewareRelationLink: Anytype_Model_RelationLink) {
        self.id = middlewareRelationLink.id
        self.key = middlewareRelationLink.key
    }
}
