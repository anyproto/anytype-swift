import Foundation
import StoredHashMacro

@StoredHash
struct MessageListAttachmentsViewData: Equatable, Hashable {
    let objects: [MessageAttachmentDetails]
    let position: MessageHorizontalPosition
}
