struct ObjectCellData: Identifiable {
    let id: String
    let icon: Icon
    let title: String
    let type: String
    let onTap: () -> Void
}