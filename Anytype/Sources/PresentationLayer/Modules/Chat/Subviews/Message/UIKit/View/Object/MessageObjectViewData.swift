//import Foundation
//import Services
//
//struct MessageObjectViewData: Equatable, Hashable {
//    let messageId: String
//    let objectId: String
//    let icon: Icon
//    let title: String
//    let description: String
//    let style: MessageAttachmentStyle
//    let size: String?
//    let syncStatus: SyncStatus?
//    let syncError: SyncError?
//}
//
//extension MessageObjectViewData {
//    init(
//        messageId: String,
//        details: ObjectDetails,
//        position: MessageHorizontalPosition
//    ) {
//        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
//        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
//        self.messageId = messageId
//        self.objectId = details.id
//        self.icon = details.objectIconImage
//        self.title = details.title
//        self.description = details.description
//        self.style = position.isRight ? .messageYour : .messageOther
//        self.size = size
//        self.syncStatus = details.syncStatusValue
//        self.syncError = details.syncErrorValue
//    }
//}
