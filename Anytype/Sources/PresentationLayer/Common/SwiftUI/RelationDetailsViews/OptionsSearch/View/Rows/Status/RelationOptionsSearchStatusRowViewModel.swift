import Foundation
import UIKit

extension RelationOptionsSearchStatusRowView {
    
    struct Model: Hashable, Identifiable {
        let id: String
        
        let text: String
        let color: UIColor
    }
    
}

extension RelationOptionsSearchStatusRowView.Model {
    
    init(option: Relation.Status.Option) {
        self.id = option.id
        self.text = option.text
        self.color = option.color
    }
    
}
