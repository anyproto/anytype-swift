import Services

struct MentionObjectModel: Identifiable {
    let object: MentionObject
    let titleBadge: String?
    
    var id: String { object.id }
}
