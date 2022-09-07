import Foundation
import ProtobufMessages

#warning("Drop this model or Relation.Tag.Option")
public extension RelationMetadata {
    
    struct Option: Hashable {
        public let id: String
        public let text: String
        public let color: String
        public let scope: Scope
    }
    
}

extension RelationMetadata.Option {
    
    public init(details: ObjectDetails) {
        self.id = details.id
        self.text = details.values["relationOptionText"]?.stringValue ?? ""
        self.color = details.values["relationOptionColor"]?.stringValue ?? ""
        #warning("Fix scope")
//        self.scope = Scope(rawValue: middlewareOption.scope.rawValue)
        self.scope = .local
    }
    
    #warning("Delete method")
    init(middlewareOption: Anytype_Model_Relation.Option) {
        self.id = middlewareOption.id
        self.text = middlewareOption.text
        self.color = middlewareOption.color
        self.scope = Scope(rawValue: middlewareOption.scope.rawValue)
    }

    #warning("Delete method")
    var asMiddleware: Anytype_Model_Relation.Option {
        Anytype_Model_Relation.Option(
            id: id,
            text: text,
            color: color,
            scope: Anytype_Model_Relation.Option.Scope(rawValue: scope.rawValue) ?? .local
        )
    }
}
