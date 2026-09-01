import Services

enum UnifiedSearchPurpose: Equatable, Hashable {
    // The default surface: results navigate
    case navigation
    // In-space object picker (attach to a message): the scope is fixed and
    // invisible, only objects are searched, selection hands the details back
    case attachToMessage
}

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
    var purpose: UnifiedSearchPurpose = .navigation
    // Seeds a chat token on top of the space scope (in-chat search entry)
    var initialChatId: String? = nil
    // attachToMessage: objects already attached - hidden from results
    var excludedObjectIds: [String] = []
    // attachToMessage: replaces onSelect - the picked object's details
    @EquatableNoop var onSelectDetails: (ObjectDetails) -> Void = { _ in }

    var id: Int { hashValue }
}
