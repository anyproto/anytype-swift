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
    
    init(searchResult: DetailsDataProtocol) {
        self.init(
            id: searchResult.blockId,
            objectIcon: searchResult.objectIcon,
            name: searchResult.mentionName,
            description: searchResult.description,
            type: searchResult.type
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

extension DetailsDataProtocol {
    var objectIcon: ObjectIconImage {
        if let objectIcon = objectIconImage {
            return objectIcon
        }
        
        return .placeholder(mentionName.first)
    }
    
    var mentionName: String {
        let name = name ?? ""
        return name.isEmpty ? "Untitled".localized : name
    }
    
    var type: ObjectType? {
        let type = ObjectTypeProvider.objectType(url: typeUrl)
        anytypeAssert(type != nil, "Cannot parse type :\(String(describing: typeUrl)))")
        return type
    }
}
