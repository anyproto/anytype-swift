struct EditorSetViewRowConfiguration: Identifiable {
    let id: String
    let name: String
    let typeName: String
    let isSupported: Bool
    let isActive: Bool
    let onTap: () -> Void
}
