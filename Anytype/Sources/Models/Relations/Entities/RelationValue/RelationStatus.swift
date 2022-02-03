import Foundation
import BlocksModels
import UIKit

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
    
    struct Option: Hashable, Identifiable {
        let id: String
        let text: String
        let color: UIColor
        let scope: RelationMetadata.Option.Scope
    }
    
}

extension Relation.Status.Option {
    
    init(option: RelationMetadata.Option) {
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        
        self.id = option.id
        self.text = option.text
        self.color = middlewareColor.map { UIColor.Text.uiColor(from: $0) } ?? UIColor.Text.default
        self.scope = option.scope
    }
    
}
