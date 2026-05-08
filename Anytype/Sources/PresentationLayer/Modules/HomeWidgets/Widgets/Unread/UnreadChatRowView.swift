import Foundation
import SwiftUI
import AnytypeCore

struct UnreadChatRowView: View {
    let data: UnreadChatRowData
    let showDivider: Bool
    let onTap: (UnreadChatRowData) -> Void

    var body: some View {
        Button {
            onTap(data)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: data.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(data.name, style: .bodySemibold)
                    .foregroundStyle(data.notificationMode == .nothing ? Color.Text.secondary : Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    if data.hasUnreadReactions {
                        HeartBadge(style: data.muted ? .muted : .highlighted)
                    }
                    if data.hasMentions {
                        MentionBadge(style: data.muted ? .muted : .highlighted)
                    }
                    if data.shouldShowUnreadCounter {
                        CounterView(count: data.unreadCounter, style: data.muted ? .muted : .highlighted)
                    }
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
    }
}
