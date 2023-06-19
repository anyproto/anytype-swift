import Services
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
    
    init(details: ObjectDetails) {
        self.init(
            id: details.id,
            objectIcon: details.objectIconImageWithPlaceholder,
            name: details.mentionTitle,
            description: details.description,
            type: details.objectType
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

