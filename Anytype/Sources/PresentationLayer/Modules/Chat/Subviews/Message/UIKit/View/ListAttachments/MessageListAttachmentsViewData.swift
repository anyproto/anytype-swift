import Foundation

struct MessageListAttachmentsViewData: Equatable, Hashable {
    let objects: [MessageAttachmentDetails]
    let position: MessageHorizontalPosition
}
