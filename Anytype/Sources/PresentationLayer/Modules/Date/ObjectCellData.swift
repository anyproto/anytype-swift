struct ObjectCellData: Identifiable, Hashable {
    let icon: Icon
    let title: String
    let type: String
    @EquatableNoop var onTap: () -> Void
    
    var id: Int { hashValue }
}
