import Foundation
import Services

struct MessageVideoViewData: Equatable {
    let url: URL?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageVideoViewData {
    init(details: MessageAttachmentDetails) {
        url = ContentUrlBuilder.fileUrl(fileId: details.id)
        syncStatus = details.syncStatus
        syncError = details.syncError
    }
}
