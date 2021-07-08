
struct MentionObject {
    
    let id: String
    let name: String?
    let description: String?
    let iconData: DocumentIconType?
}

extension MentionObject: Hashable {
    
    static func == (lhs: MentionObject, rhs: MentionObject) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
