import AnytypeCore

struct CheckPopupItem: Identifiable, Hashable {
    let id: String
    let iconAsset: ImageAsset?
    let title: String
    let subtitle: String?
    let isSelected: Bool
    @EquatableNoop private(set) var onTap: () -> Void
}
