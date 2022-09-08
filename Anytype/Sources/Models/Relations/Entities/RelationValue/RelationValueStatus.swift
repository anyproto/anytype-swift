import Foundation
import BlocksModels
import UIKit

extension RelationValue {
    
    struct Status: RelationValueProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let values: [Option]
        let allOptions: [Option]
        
        var hasValue: Bool {
            values.isNotEmpty
        }
    }
    
}

extension RelationValue.Status {
    
    struct Option: Hashable, Identifiable {
        let id: String
        let text: String
        let color: UIColor
        let scope: RelationOption.Scope
    }
    
}

extension RelationValue.Status.Option {
    
    init(option: RelationOption) {
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        
        self.id = option.id
        self.text = option.text
        self.color = middlewareColor.map { UIColor.Text.uiColor(from: $0) } ?? UIColor.Text.default
        self.scope = option.scope
    }
    
}
