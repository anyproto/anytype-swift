import Foundation
import StoredHashMacro

@StoredHash
struct MessageLayout: Equatable, Hashable {
    let cellSize: CGSize
    let iconFrame: CGRect?
    let bubbleFrame: CGRect?
    let bubbleLayout: MessageBubbleLayout?
    let reactionsFrame: CGRect?
    let reactionsLayout: MessageReactionListLayout?
    let replyFrame: CGRect?
    let replyLayout: MessageReplyLayout?
}
