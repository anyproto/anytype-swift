import Services

extension MentionObject {
    var objectIcon: Icon? { details.objectIconImage }
    var name: String { details.mentionTitle }
    var description: String? { details.description }
    var type: ObjectType? { details.objectType }
    var isDeleted: Bool { details.isDeleted }
    var isArchived: Bool { details.isArchived }
}
