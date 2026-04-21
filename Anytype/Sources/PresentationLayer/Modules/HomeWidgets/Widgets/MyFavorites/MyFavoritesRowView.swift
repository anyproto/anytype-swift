import Foundation
import SwiftUI
import Services
import AnytypeCore

struct MyFavoritesRowView: View {
    let row: MyFavoritesRowData
    let showDivider: Bool
    /// Channel widgets document for this space (`info.widgetsId`). Passed through
    /// to `WidgetActionsViewCommonMenuProvider.onChannelPinTap` so it can toggle
    /// the pin against the correct document.
    let channelWidgetsObject: any BaseDocumentProtocol
    /// Per-user personal widgets document (`info.personalWidgetsId`). Passed through
    /// to `onFavoriteTap` so the toggle runs against an already-open doc.
    let personalWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    /// Computed once at the ViewModel layer (`pinnedToChannelObjectIds`) so each
    /// row receives a plain Bool instead of opening its own subscription.
    let isPinnedToChannel: Bool

    /// Hides chat badges while the dedicated unread section is expanded — a chat's
    /// unread signal shouldn't appear in two places at once. Pushed into the
    /// environment by `HomeWidgetsView`.
    @Environment(\.shouldHideChatBadges) private var shouldHideChatBadges

    var body: some View {
        Button {
            row.onTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: row.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(row.title, style: .bodySemibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                if let chatPreview = row.chatPreview, chatPreview.hasVisibleCounters {
                    chatBadges(chatPreview: chatPreview)
                        .opacity(shouldHideChatBadges ? 0 : 1)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
        .if(FeatureFlags.personalFavorites) {
            $0.contextMenu {
                // Favorite section of a favorites row always renders "Unfavorite".
                MyFavoritesRowContextMenu(
                    objectId: row.objectId,
                    channelWidgetsObject: channelWidgetsObject,
                    personalWidgetsObject: personalWidgetsObject,
                    canManageChannelPins: canManageChannelPins,
                    isPinnedToChannel: isPinnedToChannel
                )
            }
        }
    }

    @ViewBuilder
    private func chatBadges(chatPreview: MessagePreviewModel) -> some View {
        HStack(spacing: 4) {
            if chatPreview.hasUnreadReactions {
                HeartBadge(style: chatPreview.reactionStyle)
            }
            if chatPreview.mentionCounter > 0 {
                MentionBadge(style: chatPreview.mentionCounterStyle)
            }
            if chatPreview.shouldShowUnreadCounter {
                CounterView(
                    count: chatPreview.unreadCounter,
                    style: chatPreview.unreadCounterStyle
                )
            }
        }
    }
}

/// Split out so the context menu's body does not re-compute when the outer row
/// redraws for unrelated reasons (spacing / divider).
private struct MyFavoritesRowContextMenu: View {
    let objectId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let isPinnedToChannel: Bool

    @StateObject private var model = MyFavoritesRowContextMenuViewModel()

    var body: some View {
        Button {
            model.provider.onFavoriteTap(
                targetObjectId: objectId,
                personalWidgetsObject: personalWidgetsObject
            )
        } label: {
            Text(Loc.unfavorite)
            Image(systemName: "star.fill")
        }

        if canManageChannelPins {
            Button {
                model.provider.onChannelPinTap(
                    targetObjectId: objectId,
                    channelWidgetsObject: channelWidgetsObject
                )
            } label: {
                Text(isPinnedToChannel ? Loc.unpinFromChannel : Loc.pinToChannel)
                Image(systemName: isPinnedToChannel ? "pin.slash" : "pin")
            }
        }
    }
}

private final class MyFavoritesRowContextMenuViewModel: ObservableObject {
    // Simple way for inject di. Model in this case is not needed.
    @Injected(\.widgetActionsViewCommonMenuProvider)
    var provider: any WidgetActionsViewCommonMenuProviderProtocol
}
