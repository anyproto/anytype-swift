import SwiftUI
import BlocksModels

struct SearchCellData: Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let icon: ObjectIconImage
    
    init(searchResult: ObjectDetails) {
        let title: String = {
            let title = searchResult.name
            if title.isNotEmpty {
                return title
            } else {
                return "Untitled".localized
            }
        }()
        
        let icon: ObjectIconImage = {
            let layout = searchResult.layout
            if layout == .todo {
                return .todo(searchResult.isDone)
            } else {
                return searchResult.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        
        let type: String = {
            if let type = searchResult.objectType?.name, !type.isEmpty {
                return type
            } else {
                return "Page".localized
            }
        }()
        
        self.init(
            id: searchResult.id,
            title: title,
            description: searchResult.description,
            type: type,
            icon: icon
        )
    }
    
    init(
        id: String,
        title: String,
        description: String?,
        type: String,
        icon: ObjectIconImage
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.icon = icon
    }
}
