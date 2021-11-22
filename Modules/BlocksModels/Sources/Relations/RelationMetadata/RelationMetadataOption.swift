import Foundation
import ProtobufMessages

public extension RelationMetadata {
    
    struct Option: Hashable {
        public let id: String
        public let text: String
        public let color: String
        public let scope: Scope
    }
    
}

extension RelationMetadata.Option {
    
    init(middlewareOption: Anytype_Model_Relation.Option) {
        self.id = middlewareOption.id
        self.text = middlewareOption.text
        self.color = middlewareOption.color
        self.scope = Scope(rawValue: middlewareOption.scope.rawValue)
    }
    
}
