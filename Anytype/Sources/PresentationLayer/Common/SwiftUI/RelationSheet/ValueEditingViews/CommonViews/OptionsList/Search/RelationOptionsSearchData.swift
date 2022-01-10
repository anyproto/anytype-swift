import Foundation
import BlocksModels

struct RelationOptionsSearchData: Hashable, Identifiable {
    let id: String
    
    let iconImage: ObjectIconImage
    let title: String
    let subtitle: String
}

extension RelationOptionsSearchData {
    
    init(details: ObjectDetails) {
        self.id = details.id
        
        let title = details.title
        self.iconImage = {
            if details.layout == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.objectType.name
    }
    
}
