import Foundation
import SwiftUI

struct UnreadItemsGroupedView: View {
    let items: [UnreadSectionItem]
    let onChatTap: (UnreadChatRowData) -> Void
    let onParentTap: (UnreadDiscussionParentRowData) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let showDivider = index != items.count - 1
                switch item {
                case .chat(let data):
                    UnreadChatRowView(data: data, showDivider: showDivider, onTap: onChatTap)
                case .discussionParent(let data):
                    UnreadDiscussionParentRowView(data: data, showDivider: showDivider, onTap: onParentTap)
                }
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
