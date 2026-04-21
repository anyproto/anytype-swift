import Foundation
import SwiftUI
import Services
import AnytypeCore

struct MyFavoritesRowView: View {
    let row: MyFavoritesRowData
    let showDivider: Bool
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let isPinnedToChannel: Bool

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
        .contextMenu {
            MyFavoritesRowContextMenu(
                objectId: row.objectId,
                channelWidgetsObject: channelWidgetsObject,
                personalWidgetsObject: personalWidgetsObject,
                canManageChannelPins: canManageChannelPins,
                isPinnedToChannel: isPinnedToChannel
            )
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

private struct MyFavoritesRowContextMenu: View {
    let objectId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let isPinnedToChannel: Bool

    @StateObject private var model = MyFavoritesRowContextMenuViewModel()

    var body: some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                model.provider.onFavoriteTap(
                    targetObjectId: objectId,
                    personalWidgetsObject: personalWidgetsObject
                )
            }
        } label: {
            Text(Loc.unfavorite)
            Image(systemName: "star.fill")
        }

        if canManageChannelPins {
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    model.provider.onChannelPinTap(
                        targetObjectId: objectId,
                        channelWidgetsObject: channelWidgetsObject
                    )
                }
            } label: {
                Text(isPinnedToChannel ? Loc.unpinFromChannel : Loc.pinToChannel)
                Image(systemName: isPinnedToChannel ? "pin.slash" : "pin")
            }
        }
    }
}

private final class MyFavoritesRowContextMenuViewModel: ObservableObject {
    @Injected(\.widgetActionsViewCommonMenuProvider)
    var provider: any WidgetActionsViewCommonMenuProviderProtocol
}
