import Foundation
import BlocksModels

extension Relation {
    
    struct Status: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let value: Option?
        let allOptions: [Option]
    }
    
}

extension Relation.Status {
    
    struct Option: Hashable, Identifiable, RelationValueOptionProtocol {
        let id: String
        let text: String
        let color: AnytypeColor
        let scope: RelationMetadata.Option.Scope
    }
    
}

extension Relation.Status.Option {
    
    init(option: RelationMetadata.Option) {
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        let anytypeColor: AnytypeColor = middlewareColor?.asDarkColor ?? .grayscale90
        
        self.id = option.id
        self.text = option.text
        self.color = anytypeColor
        self.scope = option.scope
    }
    
}
