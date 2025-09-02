import Foundation

struct MessageObjectViewData: Equatable {
    let icon: Icon
    let title: String
    let description: String
    let style: MessageAttachmentStyle
    let size: String?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageObjectViewData {
    init(
        details: MessageAttachmentDetails,
        position: MessageHorizontalPosition
    ) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        
        self.icon = details.objectIconImage
        self.title = details.title
        self.description = details.description
        self.style = position.isRight ? .messageYour : .messageOther
        self.size = size
        self.syncStatus = details.syncStatus
        self.syncError = details.syncError
    }
}
