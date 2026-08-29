import Services

struct UnifiedSearchModuleData: Identifiable, Hashable {
    // The space whose stores are warm (in-space entry) - seeds the scope token.
    // nil = vault entry, global scope.
    let currentSpaceId: String?
    @EquatableNoop var onSelect: (ScreenData) -> Void
    @EquatableNoop var onOpenSpace: (String) -> Void
    // Opens the message's container positioned at the message (cross-space included)
    @EquatableNoop var onOpenMessage: (_ chatObjectId: String, _ spaceId: String, _ messageId: String) -> Void
    // Set when the surface is an in-place overlay - shows the
    // Cancel button; nil when the surface is a pushed screen with a back button
    @EquatableNoop var onClose: (() -> Void)?
    // Create Channel under the Channels bucket
    @EquatableNoop var onCreatePersonalChannel: () -> Void
    @EquatableNoop var onCreateGroupChannel: () -> Void
    @EquatableNoop var onJoinQrCode: () -> Void
    // True when the entry control is a compact button: the bar springs open from
    // it. The vault's entry is already bar-shaped, so it appears in place.
    let animatesBarExpansion: Bool

    var id: Int { hashValue }
}
