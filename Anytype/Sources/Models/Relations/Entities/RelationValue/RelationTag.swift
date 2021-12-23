import Foundation
import BlocksModels
import SwiftUI

extension Relation {
    
    struct Tag: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let selectedTags: [Option]
        let allTags: [Option]
    }
    
}

extension Relation.Tag {
    
    struct Option: Hashable, Identifiable, RelationValueOptionProtocol, RelationOptionProtocol {
        let id: String
        let text: String
        let textColor: AnytypeColor
        let backgroundColor: AnytypeColor
        let scope: RelationMetadata.Option.Scope
        
        func makeView() -> AnyView {
            AnyView(TagRelationRowView(tag: self))
        }
    }
    
}

extension Relation.Tag.Option {
    
    init(option: RelationMetadata.Option) {
        self.id = option.id
        self.text = option.text
        self.textColor = MiddlewareColor(rawValue: option.color)?.asDarkColor ?? .grayscale90
        self.backgroundColor = MiddlewareColor(rawValue: option.color)?.asLightColor ?? .grayscaleWhite
        self.scope = option.scope
    }
    
}
