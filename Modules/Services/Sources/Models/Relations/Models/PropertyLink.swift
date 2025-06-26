import Foundation
import ProtobufMessages

public struct PropertyLink: Hashable, Sendable {
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
}

public extension PropertyLink {
    
    init(middlewarePropertyLink: Anytype_Model_RelationLink) {
        self.key = middlewarePropertyLink.key
    }
    
    var asMiddleware: Anytype_Model_RelationLink {
        Anytype_Model_RelationLink.with {
            $0.key = key
        }
    }
}
