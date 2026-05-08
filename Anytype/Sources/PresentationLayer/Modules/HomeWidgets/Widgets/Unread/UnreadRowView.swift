import Foundation
import SwiftUI
import AnytypeCore

struct UnreadRowView: View {
    let data: UnreadSectionRowData
    let showDivider: Bool
    let onTap: (UnreadSectionRowData) -> Void

    var body: some View {
        Button {
            onTap(data)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: data.details.objectIconImage)
                    .frame(width: 20, height: 20)

                AnytypeText(data.details.pluralTitle, style: .bodySemibold)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)

                Spacer()

                accessory
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
    }

    private var titleColor: Color {
        data.notificationMode == .nothing ? .Text.secondary : .Text.primary
    }

    @ViewBuilder
    private var accessory: some View {
        let mode = data.notificationMode
        HStack(spacing: 4) {
            if data.hasUnreadReactions {
                HeartBadge(style: mode.reactionCounterStyle)
            }
            if data.unreadMentionCount > 0 {
                MentionBadge(style: mode.mentionCounterStyle)
            }
            if mode.shouldShowUnreadCounter(unreadCount: data.unreadMessageCount, isSubscribed: data.isSubscribed) {
                CounterView(count: data.unreadMessageCount, style: mode.unreadCounterStyle)
            }
        }
    }
}
