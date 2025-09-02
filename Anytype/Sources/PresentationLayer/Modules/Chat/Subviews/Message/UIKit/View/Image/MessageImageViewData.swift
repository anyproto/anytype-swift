import Foundation
import Services

struct MessageImageViewData: Equatable {
    let messageId: String
    let objectId: String
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageImageViewData {
    init(messageId: String, details: MessageAttachmentDetails) {
        self.messageId = messageId
        self.objectId = details.id
        self.syncStatus = details.syncStatus
        self.syncError = details.syncError
    }
}
