struct EditorSetViewRowConfiguration: Identifiable, Equatable {
    let id: String
    let name: String
    let typeName: String
    let isSupported: Bool
    let isActive: Bool
    @EquatableNoop var onTap: () -> Void
    @EquatableNoop var onEditTap: () -> Void
}
