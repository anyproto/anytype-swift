struct SetFilterRowConfiguration: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let iconName: String
    let relation: Relation
    let onTap: () -> Void
    
    static func == (lhs: SetFilterRowConfiguration, rhs: SetFilterRowConfiguration) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.iconName == rhs.iconName &&
        lhs.relation == rhs.relation
    }
}
