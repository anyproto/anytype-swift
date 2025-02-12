import Services

struct RelationItemData: Identifiable, Hashable {
    let id: String
    let icon: Icon?
    let title: String
    let details: RelationDetails
}
