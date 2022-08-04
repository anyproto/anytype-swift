struct EditorSetViewSettingsConfiguration: Identifiable, Equatable {
    struct Relation: Identifiable, Equatable {
        let id: String
        let image: ImageAsset
        let title: String
        let isOn: Bool
        let isBundled: Bool
        @EquatableNoop var onChange: (Bool) -> Void
    }
    let id: String
    let settingsName: String
    let iconIsHidden: Bool
    let relations: [Relation]
    @EquatableNoop var onSettingsChange: (Bool) -> Void
    
    static let empty: EditorSetViewSettingsConfiguration = EditorSetViewSettingsConfiguration(
        id: "",
        settingsName: "",
        iconIsHidden: true,
        relations: [],
        onSettingsChange: { _ in }
    )
}
