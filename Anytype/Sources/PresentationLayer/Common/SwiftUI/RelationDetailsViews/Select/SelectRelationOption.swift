import SwiftUI
import Services

struct SelectRelationOption: Equatable, Identifiable {
    let id: String
    let text: String
    let color: Color
}

extension SelectRelationOption {
    
    init(relation: RelationOption) {
        let middlewareColor = MiddlewareColor(rawValue: relation.color)
        
        self.id = relation.id
        self.text = relation.text
        self.color = middlewareColor.map { UIColor.Dark.uiColor(from: $0) }?.suColor ?? Color.Dark.default
    }
    
}

