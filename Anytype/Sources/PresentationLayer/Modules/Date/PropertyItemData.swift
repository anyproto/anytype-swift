import Services

struct PropertyItemData: Identifiable, Hashable {
    let id: String
    let icon: Icon?
    let title: String
    let details: RelationDetails
}
