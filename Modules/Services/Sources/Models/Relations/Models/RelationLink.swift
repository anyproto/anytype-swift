import Foundation
import ProtobufMessages

public struct RelationLink: Hashable, Sendable {
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
}

public extension RelationLink {
    
    init(middlewareRelationLink: Anytype_Model_RelationLink) {
        self.key = middlewareRelationLink.key
    }
    
    var asMiddleware: Anytype_Model_RelationLink {
        Anytype_Model_RelationLink.with {
            $0.key = key
        }
    }
}
