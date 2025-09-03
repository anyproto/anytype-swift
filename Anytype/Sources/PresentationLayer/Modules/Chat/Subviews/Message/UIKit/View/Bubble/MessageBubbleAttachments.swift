import Foundation

enum MessageBubbleAttachments: Equatable, Hashable {
    case list(MessageListAttachmentsViewData)
    case grid([MessageAttachmentDetails])
    case bookmark(MessageBigBookmarkViewData)
}
