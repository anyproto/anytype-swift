import SwiftUI
import Services

struct MultiSelectRelationOption: Equatable, Identifiable {
    let id: String
    let text: String
    let textColor: Color
    let backgroundColor: Color
}

extension MultiSelectRelationOption {
    
    init(relation: RelationOption) {
        let middlewareColor = MiddlewareColor(rawValue: relation.color)
        
        self.id = relation.id
        self.text = relation.text
        self.textColor = middlewareColor.map { Color.Dark.color(from: $0) } ?? Color.Dark.grey
        self.backgroundColor = middlewareColor.map { Color.VeryLight.color(from: $0) } ?? Color.VeryLight.grey
    }
    
    init(optionParams: RelationOptionParameters) {
        self.id = optionParams.id
        self.text = optionParams.text
        self.textColor = optionParams.color
        self.backgroundColor = optionParams.color.middlewareColor().map { Color.VeryLight.color(from: $0) } ?? Color.VeryLight.grey
    }
    
}

