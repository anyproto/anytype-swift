import Services

struct GlobalSearchModuleData: Identifiable, Hashable {
    let spaceId: String
    @EquatableNoop var onSelect: (ScreenData) -> Void
    
    var id: Int { hashValue }
}
