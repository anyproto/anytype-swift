struct SetViewTypeConfiguration: Identifiable {
    let id: String
    let icon: ImageAsset
    let name: String
    let isSelected: Bool
    let onTap: () -> Void
}
