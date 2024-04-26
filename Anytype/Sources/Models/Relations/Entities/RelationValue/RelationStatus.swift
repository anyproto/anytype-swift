import Foundation
import Services
import UIKit

extension Relation {
    
    struct Status: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        
        let values: [Option]
        
        var hasValue: Bool {
            values.isNotEmpty
        }
    }
    
}

extension Relation.Status {
    
    struct Option: Hashable, Identifiable {
        let id: String
        let text: String
        let color: UIColor
    }
    
}

extension Relation.Status.Option {
    
    init(option: RelationOption) {
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        
        self.id = option.id
        self.text = option.text
        self.color = middlewareColor.map { UIColor.Dark.uiColor(from: $0) } ?? UIColor.Dark.default
    }
    
}
