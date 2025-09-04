import Foundation
import Services

struct MessageVideoViewData: Equatable {
    let objectId: String
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageVideoViewData {
    init(details: MessageAttachmentDetails) {
        self.objectId = details.id
        self.syncStatus = details.syncStatus
        self.syncError = details.syncError
    }
}
