import Foundation
import SwiftUI

struct UnreadChatsGroupedView: View {
    let chats: [UnreadChatWidgetData]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(chats.enumerated()), id: \.element.id) { index, chatData in
                UnreadChatRowView(
                    data: chatData,
                    showDivider: index != chats.count - 1
                )
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
