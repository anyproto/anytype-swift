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
    case relation(Property?)
    case date(String)
}
