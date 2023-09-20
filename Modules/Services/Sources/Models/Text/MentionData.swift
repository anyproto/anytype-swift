import AnytypeCore

public struct MentionObject: Equatable, Hashable {
    public let details: ObjectDetails
    public var id: BlockId { details.id }
    
//    let id: String
//    let objectIcon: Icon?
//    let name: String
//    let description: String?
//    let type: ObjectType?
//    let isDeleted: Bool
//    let isArchived: Bool
    
//    init(
//        id: String,
//        objectIcon: Icon?,
//        name: String,
//        description: String?,
//        type: ObjectType?,
//        isDeleted: Bool,
//        isArchived: Bool
//    ) {
//        self.id = id
//        self.objectIcon = objectIcon
//        self.name = name
//        self.description = description
//        self.type = type
//        self.isDeleted = isDeleted
//        self.isArchived = isArchived
//    }
    
    public init(details: ObjectDetails) {
        self.details = details
//        self.init(details: details)
//        self.init(
//            id: details.id,
////            objectIcon: details.objectIconImage,
////            name: details.mentionTitle,
//            description: details.description,
//            type: details.objectType,
//            isDeleted: details.isDeleted,
//            isArchived: details.isArchived
//        )
    }
}

public extension MentionObject {
    static func == (lhs: MentionObject, rhs: MentionObject) -> Bool {
        lhs.details == rhs.details
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(details)
    }
}

extension MentionObject {
    public static func noDetails(blockId: BlockId) -> MentionObject {
        MentionObject(details: .init(id: blockId))
    }
}
