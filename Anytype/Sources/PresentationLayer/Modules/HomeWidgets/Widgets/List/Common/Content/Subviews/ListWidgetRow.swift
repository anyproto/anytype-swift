import Foundation
import SwiftUI

struct ListWidgetRow: View {
    
    let model: ListWidgetRowModel
    let showDivider: Bool
    
    @Environment(\.editMode) private var editMode
    @Environment(\.shouldHideChatBadges) private var shouldHideChatBadges

    var body: some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 0) {
                IconView(icon: model.icon)
                    .frame(width: 48, height: 48)

                Spacer.fixedWidth(12)

                if let chatPreview = model.chatPreview {
                    chatContent(chatPreview: chatPreview)
                } else if let parentBadge = model.parentBadge, parentBadge.hasVisibleCounters {
                    parentContent(badge: parentBadge)
                } else {
                    regularContent
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 72)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
        .id(model.objectId)
    }

    @ViewBuilder
    private var regularContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(model.title, style: .previewTitle2Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
            if let description = model.description, description.isNotEmpty {
                Spacer.fixedHeight(1)
                AnytypeText(description, style: .relation3Regular)
                    .foregroundStyle(Color.Widget.secondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func parentContent(badge: ParentObjectUnreadBadge) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                AnytypeText(model.title, style: .previewTitle2Medium)
                    .foregroundStyle(badge.titleColor)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    if badge.hasMentions {
                        MentionBadge(style: badge.notificationMode.mentionCounterStyle)
                    }
                    if badge.shouldShowUnreadCounter {
                        CounterView(
                            count: badge.unreadMessageCount,
                            style: badge.notificationMode.unreadCounterStyle
                        )
                    }
                }
                .opacity(shouldHideChatBadges ? 0 : 1)
            }
            if let description = model.description, description.isNotEmpty {
                Spacer.fixedHeight(1)
                AnytypeText(description, style: .relation3Regular)
                    .foregroundStyle(Color.Widget.secondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func chatContent(chatPreview: MessagePreviewModel) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 0) {
                AnytypeText(model.title, style: .previewTitle2Medium)
                    .foregroundStyle(chatPreview.titleColor)
                    .lineLimit(1)

                Spacer()

                AnytypeText(chatPreview.chatPreviewDate, style: .relation3Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 0) {
                AnytypeText(chatPreview.messagePreviewText, style: .relation2Regular)
                    .foregroundStyle(chatPreview.messagePreviewColor)
                    .lineLimit(1)

                Spacer()

                if chatPreview.hasVisibleCounters {
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
                    .opacity(shouldHideChatBadges ? 0 : 1)
                }
            }
        }
    }
}
