
struct MentionObject {
    let id: String
    let icon: MentionIcon?
    let name: String?
    let description: String?
    let type: ObjectType?
}

extension MentionObject: Hashable {
    
    static func == (lhs: MentionObject, rhs: MentionObject) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
