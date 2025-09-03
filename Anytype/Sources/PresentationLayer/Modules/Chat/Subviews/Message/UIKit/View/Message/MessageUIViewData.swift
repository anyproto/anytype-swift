import Foundation
import StoredHashMacro

@StoredHash
struct MessageUIViewData: Equatable, Hashable {
    let id: String
    let orderId: String
    let authorIcon: Icon
    let authorIconMode: MessageAuthorIconMode
    let bubble: MessageBubbleViewData
    let reply: MessageReplyViewData?
    let reactions: MessageReactionListData?
    let nextSpacing: MessageViewSpacing
    let position: MessageHorizontalPosition
}
