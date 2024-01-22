enum MentionDisplayData: Hashable {
    case mention(MentionObject)
    case createNewObject(objectName: String)
}
