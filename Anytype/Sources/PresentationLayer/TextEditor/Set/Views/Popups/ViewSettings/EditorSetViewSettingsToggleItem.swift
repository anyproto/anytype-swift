struct EditorSetViewSettingsToggleItem {
    let title: String
    let isSelected: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}
