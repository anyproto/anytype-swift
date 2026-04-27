import Foundation
import SwiftUI

struct UnreadDiscussionParentRowView: View {
    let data: UnreadDiscussionParentWidgetData
    let showDivider: Bool

    @State private var model: UnreadDiscussionParentWidgetViewModel

    init(data: UnreadDiscussionParentWidgetData, showDivider: Bool) {
        self.data = data
        self.showDivider = showDivider
        self._model = State(initialValue: UnreadDiscussionParentWidgetViewModel(data: data))
    }

    var body: some View {
        Button {
            model.onHeaderTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: model.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(model.name, style: .bodySemibold)
                    .foregroundStyle(model.notificationMode == .nothing ? Color.Text.secondary : Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                if let badge = model.badge {
                    ParentBadgesView(badge: badge)
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
