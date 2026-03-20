import Foundation
import SwiftUI
import AnytypeCore

struct UnreadChatRowView: View {
    let data: UnreadChatWidgetData
    let showDivider: Bool

    @State private var model: UnreadChatWidgetViewModel

    init(data: UnreadChatWidgetData, showDivider: Bool) {
        self.data = data
        self.showDivider = showDivider
        self._model = State(initialValue: UnreadChatWidgetViewModel(data: data))
    }

    var body: some View {
        Button {
            model.onHeaderTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: model.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(model.name, style: .bodySemibold)
                    .foregroundStyle(model.muted ? Color.Text.secondary : Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    if model.hasUnreadReactions {
                        HeartBadge(style: model.muted ? .muted : .highlighted)
                    }
                    if model.hasMentions {
                        MentionBadge(style: model.muted ? .muted : .highlighted)
                    }
                    if model.unreadCounter > 0 && !(FeatureFlags.muteAndHide && model.notificationMode == .nothing) {
                        CounterView(count: model.unreadCounter, style: model.muted ? .muted : .highlighted)
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
        .task {
            await model.startSubscriptions()
        }
    }
}
