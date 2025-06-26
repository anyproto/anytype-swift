import Foundation
import Services
import SwiftUI

extension Relation {
    
    struct Status: PropertyProtocol, Hashable, Identifiable {
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
        let color: Color
    }
    
}

extension Relation.Status.Option {
    
    init(option: PropertyOption) {
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        
        self.id = option.id
        self.text = option.text
        self.color = middlewareColor.map { Color.Dark.color(from: $0) } ?? Color.Dark.default
    }
    
}
