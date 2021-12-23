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

    var middlewareModel: Anytype_Model_Relation.Option {
        Anytype_Model_Relation.Option(
            id: id,
            text: text,
            color: color,
            scope: Anytype_Model_Relation.Option.Scope(rawValue: scope.rawValue) ?? .local
        )
    }
}
