struct EditorSetViewSettingsConfiguration {
    let iconSetting: EditorSetViewSettingsToggleItem
    let coverFitSetting: EditorSetViewSettingsToggleItem
    let relations: [EditorSetViewSettingsRelation]
    let needShowAllSettings: Bool
    
    static let empty: EditorSetViewSettingsConfiguration = EditorSetViewSettingsConfiguration(
        iconSetting: EditorSetViewSettingsToggleItem(title: "", isSelected: false, onChange: { _ in }),
        coverFitSetting: EditorSetViewSettingsToggleItem(title: "", isSelected: false, onChange: { _ in }),
        relations: [],
        needShowAllSettings: false
    )
}
