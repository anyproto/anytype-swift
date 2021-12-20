import Foundation

struct RelationObjectsSearchData: Hashable, Identifiable {
    let id: String
    
    let iconImage: ObjectIconImage
    let title: String
    let subtitle: String
    
    init(searchData: SearchData) {
        self.id = searchData.id
        
        let title = searchData.name
        self.iconImage = {
            if searchData.layout == .todo {
                return .todo(searchData.isDone)
            } else {
                return searchData.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = searchData.objectType.name
    }
    
}
