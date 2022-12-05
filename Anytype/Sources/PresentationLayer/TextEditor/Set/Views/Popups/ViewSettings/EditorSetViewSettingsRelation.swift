struct EditorSetViewSettingsRelation: Identifiable {
    let id: String
    let image: ImageAsset
    let title: String
    let isOn: Bool
    let isSystem: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}
