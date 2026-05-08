import Foundation
import SwiftUI

struct UnreadDiscussionParentRowView: View {
    let data: UnreadDiscussionParentRowData
    let showDivider: Bool
    let onTap: (UnreadDiscussionParentRowData) -> Void

    var body: some View {
        Button {
            onTap(data)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: data.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(data.name, style: .bodySemibold)
                    .foregroundStyle(data.badge.titleColor)
                    .lineLimit(1)

                Spacer()

                if data.badge.hasVisibleCounters {
                    ParentBadgesView(badge: data.badge)
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
