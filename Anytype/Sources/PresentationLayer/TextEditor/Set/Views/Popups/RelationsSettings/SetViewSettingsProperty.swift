struct SetViewSettingsProperty: Identifiable, Equatable {
    let id: String
    let image: ImageAsset
    let title: String
    let isOn: Bool
    let canBeRemoved: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}
