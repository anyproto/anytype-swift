import Services

struct GlobalSearchModuleData: Identifiable, Hashable {
    let spaceId: String
    @EquatableNoop var onSelect: (EditorScreenData) -> Void
    
    var id: Int { hashValue }
}
