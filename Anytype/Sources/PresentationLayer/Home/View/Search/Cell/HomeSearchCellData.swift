import SwiftUI

struct HomeSearchCellData: Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let icon: ObjectIconImage
    
    init(searchResult: SearchResult) {
        let title: String = {
            if let title = searchResult.name, !title.isEmpty {
                return title
            } else {
                return "Untitled".localized
            }
        }()
        
        let icon: ObjectIconImage = {
            if let layout = searchResult.layout, layout == .todo {
                return .todo(searchResult.done ?? false)
            } else {
                return searchResult.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        
        let type: String = {
            if let type = searchResult.type?.name, !type.isEmpty {
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
