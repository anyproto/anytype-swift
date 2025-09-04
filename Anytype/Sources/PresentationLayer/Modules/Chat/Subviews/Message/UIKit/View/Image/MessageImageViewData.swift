import Foundation
import Services

struct MessageImageViewData: Equatable {
    let objectId: String
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageImageViewData {
    init(details: MessageAttachmentDetails) {
        self.objectId = details.id
        self.syncStatus = details.syncStatus
        self.syncError = details.syncError
    }
}
