import Foundation

struct MessageListAttachmentsViewData: Equatable, Hashable {
    let messageId: String
    let objects: [MessageAttachmentDetails]
    let position: MessageHorizontalPosition
}
