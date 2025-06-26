import Foundation
import Services
import SwiftUI

extension Relation {
    
    struct Tag: PropertyProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        
        let selectedTags: [Option]
        
        var hasValue: Bool {
            selectedTags.isNotEmpty
        }
    }
    
}

extension Relation.Tag {
    
    struct Option: Hashable, Identifiable {
        let id: String
        let text: String
        let textColor: Color
        let backgroundColor: Color
    }
    
}

extension Relation.Tag.Option {
    
    init(option: PropertyOption) {
        self.id = option.id
        self.text = option.text
        self.textColor = MiddlewareColor(rawValue: option.color)
            .map { Color.Dark.color(from: $0) } ?? .Text.secondary
        self.backgroundColor = MiddlewareColor(rawValue: option.color)
            .map { Color.VeryLight.color(from: $0) } ?? .Background.secondary
    }
    
}
