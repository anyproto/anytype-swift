import Services

struct UnifiedSearchModuleData: Identifiable, Hashable {
    // The space whose stores are warm (in-space entry) - seeds the scope token.
    // nil = vault entry, global scope.
    let currentSpaceId: String?
    @EquatableNoop var onSelect: (ScreenData) -> Void
    @EquatableNoop var onOpenSpace: (String) -> Void

    var id: Int { hashValue }
}
