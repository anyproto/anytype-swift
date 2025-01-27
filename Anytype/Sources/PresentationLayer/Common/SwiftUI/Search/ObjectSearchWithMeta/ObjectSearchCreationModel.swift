import Services

struct ObjectSearchCreationModel: Identifiable, Hashable {
    let title: String
    @EquatableNoop var onTap: () -> Void
    
    var id: Int { hashValue }
}
