import Foundation
import StoredHashMacro

@StoredHash
struct MessageBubbleLayout: Equatable, Hashable {
    let bubbleSize: CGSize
    let textFrame: CGRect?
    let textLayout: MessageTextLayout?
    let gridAttachmentsFrame: CGRect?
    let gridAttachmentsLayout: MessageGridAttachmentsContainerLayout?
    let bigBookmarkFrame: CGRect?
    let bigBookmarkLayout: MessageBigBookmarkLayout?
    let listAttachmentsFrame: CGRect?
    let listAttachmentsLayout: MessageListAttachmentsLayout?
}
