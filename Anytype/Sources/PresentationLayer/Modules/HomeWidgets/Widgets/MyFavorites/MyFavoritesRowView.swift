import Foundation
import SwiftUI
import Services
import AnytypeCore

struct MyFavoritesRowView: View {
    let row: MyFavoritesRowData
    let showDivider: Bool
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol

    var body: some View {
        MyFavoritesRowInternalView(
            row: row,
            showDivider: showDivider,
            spaceId: spaceId,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject
        )
        .id(row.id)
    }
}

private struct MyFavoritesRowInternalView: View {
    let row: MyFavoritesRowData
    let showDivider: Bool
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol

    @State private var rowModel: MyFavoritesRowViewModel

    @Environment(\.shouldHideChatBadges) private var shouldHideChatBadges

    init(
        row: MyFavoritesRowData,
        showDivider: Bool,
        spaceId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol
    ) {
        self.row = row
        self.showDivider = showDivider
        self.spaceId = spaceId
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        _rowModel = State(initialValue: MyFavoritesRowViewModel(objectId: row.objectId, spaceId: spaceId))
    }

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

                if let chatPreview = rowModel.badgeModel, chatPreview.hasVisibleCounters {
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
        .background(Color.Background.widget)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contextMenu {
            MyFavoritesRowContextMenu(
                objectId: row.objectId,
                spaceId: spaceId,
                channelWidgetsObject: channelWidgetsObject,
                personalWidgetsObject: personalWidgetsObject
            )
        }
        .task {
            await rowModel.startSubscriptions()
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
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol

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

        if model.canManageChannelPins(spaceId: spaceId) {
            let isPinnedToChannel = model.isPinnedToChannel(
                objectId: objectId,
                channelWidgetsObject: channelWidgetsObject
            )
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
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    func canManageChannelPins(spaceId: String) -> Bool {
        participantSpacesStorage
            .participantSpaceView(spaceId: spaceId)?
            .canManageChannelPins ?? false
    }

    func isPinnedToChannel(objectId: String, channelWidgetsObject: any BaseDocumentProtocol) -> Bool {
        for block in channelWidgetsObject.children where block.isWidget {
            guard let info = channelWidgetsObject.widgetInfo(block: block),
                  case let .object(details) = info.source else { continue }
            if details.id == objectId { return true }
        }
        return false
    }
}
