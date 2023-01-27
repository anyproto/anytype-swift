struct SetSortRowConfiguration: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let iconAsset: ImageAsset
    @EquatableNoop var onTap: () -> Void
}
