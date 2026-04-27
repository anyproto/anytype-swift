import Foundation
import SwiftUI

struct ListWidgetCompactRow: View {
    
    let model: ListWidgetRowModel
    let showDivider: Bool
    
    @Environment(\.editMode) private var editMode
    @Environment(\.shouldHideChatBadges) private var shouldHideChatBadges

    private var titleColor: Color {
        model.chatPreview?.titleColor ?? model.parentBadge?.titleColor ?? .Text.primary
    }

    var body: some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: model.icon)
                    .frame(width: 18, height: 18)

                AnytypeText(model.title, style: .previewTitle2Medium)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)

                Spacer()

                if let chatPreview = model.chatPreview, chatPreview.hasVisibleCounters {
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
                } else if let parentBadge = model.parentBadge, parentBadge.hasVisibleCounters {
                    HStack(spacing: 4) {
                        if parentBadge.hasMentions {
                            MentionBadge(style: parentBadge.notificationMode.mentionCounterStyle)
                        }
                        if parentBadge.shouldShowUnreadCounter {
                            CounterView(
                                count: parentBadge.unreadMessageCount,
                                style: parentBadge.notificationMode.unreadCounterStyle
                            )
                        }
                    }
                    .opacity(shouldHideChatBadges ? 0 : 1)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
    }
}
