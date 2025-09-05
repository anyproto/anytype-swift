import Foundation
import StoredHashMacro
import UIKit

@StoredHash
struct MessageUIViewData: Equatable, Hashable {
    let id: String
    let orderId: String
    let authorName: NSAttributedString
    let authorIcon: Icon
    let authorIconMode: MessageAuthorIconMode
    let bubble: MessageBubbleViewData
    let reply: MessageReplyViewData?
    let reactions: MessageReactionListData?
    let nextSpacing: MessageViewSpacing
    let position: MessageHorizontalPosition
    
    static let authorLineLimit = 1
}

extension MessageUIViewData {
    init(
        id: String,
        orderId: String,
        authorName: String,
        authorIcon: Icon,
        authorIconMode: MessageAuthorIconMode,
        bubble: MessageBubbleViewData,
        reply: MessageReplyViewData?,
        reactions: MessageReactionListData?,
        nextSpacing: MessageViewSpacing,
        position: MessageHorizontalPosition
    ) {
        self.init(
            id: id,
            orderId: orderId,
            authorName: NSAttributedString(
                string: authorName.isNotEmpty ? authorName : " ", // Safe height if participant is not loaded
                attributes: [.font: UIFont.caption1Medium]
            ),
            authorIcon: authorIcon,
            authorIconMode: authorIconMode,
            bubble: bubble,
            reply: reply,
            reactions: reactions,
            nextSpacing: nextSpacing,
            position: position
        )
    }
}
