import Services

struct ObjectSearchWithMetaModuleData: Identifiable, Hashable {
    let spaceId: String
    let excludedObjectIds: [String]
    @EquatableNoop var onSelect: (ObjectDetails) -> Void
    
    var id: Int { hashValue }
}
