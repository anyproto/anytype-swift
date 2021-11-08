import BlocksModels
import AnytypeCore

struct MentionObject {
    let id: String
    let objectIcon: ObjectIconImage
    let name: String
    let description: String?
    let type: ObjectType?
    
    init(
        id: String,
        objectIcon: ObjectIconImage,
        name: String,
        description: String?,
        type: ObjectType?
    ) {
        self.id = id
        self.objectIcon = objectIcon
        self.name = name
        self.description = description
        self.type = type
    }
    
    init(searchResult: SearchData) {
        self.init(
            id: searchResult.id,
            objectIcon: searchResult.objectIcon,
            name: searchResult.mentionTitle,
            description: searchResult.description,
            type: searchResult.objectType
        )
    }
}

extension MentionObject: Hashable {
    
    static func == (lhs: MentionObject, rhs: MentionObject) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

private extension SearchData {
    
    var objectIcon: ObjectIconImage {
        if let objectIcon = objectIconImage {
            return objectIcon
        }
        
        return .placeholder(title.first)
    }
    
}
