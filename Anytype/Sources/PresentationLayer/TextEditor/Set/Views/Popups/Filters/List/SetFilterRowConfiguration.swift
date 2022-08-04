struct SetFilterRowConfiguration: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let iconAsset: ImageAsset
    let type: SetFilterRowType
    let hasValues: Bool
    @EquatableNoop var onTap: () -> Void
}

enum SetFilterRowType: Equatable {
    case relation(Relation?)
    case date(String)
}
