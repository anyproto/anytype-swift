struct SimpleSearchListItem: Identifiable, Hashable {
    let icon: Icon?
    let title: String
    @EquatableNoop var onTap: () -> Void
    
    var id: Int { hashValue }
}
