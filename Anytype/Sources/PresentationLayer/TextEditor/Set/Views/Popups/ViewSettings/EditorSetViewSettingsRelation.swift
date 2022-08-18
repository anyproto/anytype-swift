struct EditorSetViewSettingsRelation: Identifiable {
    let id: String
    let image: ImageAsset
    let title: String
    let isOn: Bool
    let isBundled: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}
