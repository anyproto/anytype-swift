import Services

struct RelationItemData: Identifiable, Hashable {
    let icon: Icon?
    let title: String
    let details: RelationDetails
    
    var id: Int { hashValue }
}
