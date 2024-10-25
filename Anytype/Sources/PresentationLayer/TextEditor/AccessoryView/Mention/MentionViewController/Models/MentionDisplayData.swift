import Services

enum MentionDisplayData: Hashable {
    case header(title: String)
    case mention(MentionObject)
    case createNewObject(objectName: String)
    case selectDate
}
