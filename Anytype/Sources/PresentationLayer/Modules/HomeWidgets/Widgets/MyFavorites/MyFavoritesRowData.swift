import Foundation

// View-data for a single row in the My Favorites section. Built by
// `MyFavoritesViewModel` from `ObjectDetails` + the widget-block id, so the row
// view renders from flat fields and doesn't need to know about `ObjectDetails`.
// Matches the shape used by `ListWidgetRowModel` for channel-pin rows — closure
// pre-bound at row-build time captures the navigation target, keeping the view
// layer decoupled from routing semantics.
struct MyFavoritesRowData: Identifiable, Equatable {
    /// Widget block id inside the personal widgets virtual document. Stable per
    /// favorite; used as SwiftUI identity and as the block id handed to reorder /
    /// remove RPCs.
    let id: String
    /// Target object id the favorite points to. Used by the long-press context
    /// menu to toggle favorite / channel-pin state.
    let objectId: String
    let title: String
    let icon: Icon
    /// Non-nil only when the favorited object is a chat with a last message.
    /// Drives the unread-counter / mention / reaction badges — gated view-side by
    /// `\.shouldHideChatBadges` so they hide while the unread section is expanded.
    let chatPreview: MessagePreviewModel?
    @EquatableNoop var onTap: @MainActor () -> Void
}
