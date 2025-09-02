import Foundation
import Services

struct MessageImageViewData: Equatable {
    let imageId: String
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageImageViewData {
    init(details: MessageAttachmentDetails) {
        self.imageId = details.id
        self.syncStatus = details.syncStatus
        self.syncError = details.syncError
    }
}
