import Foundation
import SwiftUI

struct UnreadItemsGroupedView: View {
    let items: [UnreadSectionItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let showDivider = index != items.count - 1
                switch item {
                case .chat(let data, _):
                    UnreadChatRowView(data: data, showDivider: showDivider)
                case .discussionParent(let data, _):
                    UnreadDiscussionParentRowView(data: data, showDivider: showDivider)
                }
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
