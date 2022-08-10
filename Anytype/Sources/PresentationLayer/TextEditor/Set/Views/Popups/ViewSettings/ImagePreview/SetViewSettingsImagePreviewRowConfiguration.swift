struct SetViewSettingsImagePreviewRowConfiguration: Identifiable, Equatable {
    let id: String
    let iconAsset: ImageAsset?
    let title: String
    let isSelected: Bool
    @EquatableNoop var onTap: () -> Void
}
