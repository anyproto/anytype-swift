import Foundation
import BlocksModels

extension RelationValue {
    
    struct Status: Hashable, Identifiable {
        let id: String
        let text: String
        let color: AnytypeColor
    }
    
}

extension RelationValue.Status {
    
    init(option: RelationMetadata.Option) {
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        let anytypeColor: AnytypeColor = middlewareColor?.asDarkColor ?? .grayscale90
        
        self.id = option.id
        self.text = option.text
        self.color = anytypeColor
    }
    
}
