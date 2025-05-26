import SwiftUI
import Services

struct SelectPropertyOption: Equatable, Identifiable {
    let id: String
    let text: String
    let color: Color
}

extension SelectPropertyOption {
    
    init(relation: RelationOption) {
        let middlewareColor = MiddlewareColor(rawValue: relation.color)
        
        self.id = relation.id
        self.text = relation.text
        self.color = middlewareColor.map { Color.Dark.color(from: $0) } ?? Color.Dark.grey
    }
    
    init(optionParams: RelationOptionParameters) {
        self.id = optionParams.id
        self.text = optionParams.text
        self.color = optionParams.color
    }
}

