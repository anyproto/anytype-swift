import Foundation
import SwiftUI
import Services

struct MyFavoritesRowInternalView: View {
    private let showDivider: Bool

    @State private var rowModel: MyFavoritesRowViewModel

    @Environment(\.shouldHideChatBadges) private var shouldHideChatBadges

    init(
        row: MyFavoritesRowData,
        showDivider: Bool,
        spaceId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.showDivider = showDivider
        _rowModel = State(initialValue: MyFavoritesRowViewModel(
            widgetBlockId: row.id,
            details: row.details,
            spaceId: spaceId,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject,
            onObjectSelected: onObjectSelected
        ))
    }

    var body: some View {
        Button {
            rowModel.onTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: rowModel.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(rowModel.title, style: .bodySemibold)
                    .foregroundStyle(rowModel.titleColor)
                    .lineLimit(1)

                Spacer()

                if let chatPreview = rowModel.badgeModel, chatPreview.hasVisibleCounters {
                    chatBadges(chatPreview: chatPreview)
                        .opacity(shouldHideChatBadges ? 0 : 1)
                } else if let parentBadge = rowModel.parentBadge, parentBadge.hasVisibleCounters {
                    ParentBadgesView(badge: parentBadge)
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
            MyFavoritesRowContextMenu(model: rowModel.menuViewModel)
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
