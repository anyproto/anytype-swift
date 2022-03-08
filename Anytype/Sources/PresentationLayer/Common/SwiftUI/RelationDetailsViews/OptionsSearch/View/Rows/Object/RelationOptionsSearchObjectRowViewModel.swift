import Foundation
import BlocksModels

extension RelationOptionsSearchObjectRowView {
    
    struct Model: Hashable, Identifiable {
        let id: String
        let icon: ObjectIconImage
        let title: String
        let subtitle: String
        
        let isSelected: Bool
    }
    
}

extension RelationOptionsSearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        self.id = details.id
        
        let title = details.title
        self.icon = {
            if details.layout == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.objectType.name
        self.isSelected = false
    }
    
}
