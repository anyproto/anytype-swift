struct SetViewTypeConfiguration: Identifiable {
    let id: String
    let icon: ImageAsset
    let name: String
    let isSupported: Bool
    let isSelected: Bool
    let onTap: () -> Void
}
