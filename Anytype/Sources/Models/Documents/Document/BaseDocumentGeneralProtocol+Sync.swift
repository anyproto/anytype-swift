import Foundation
import Services
import Combine

struct DocumentSyncStatusData: Equatable {
    let syncStatus: SyncStatus
    let layout: DetailsLayout
}

extension BaseDocumentGeneralProtocol {
    
    var syncStatusPublisher: AnyPublisher<DocumentSyncStatusData, Never> {
        syncPublisher.compactMap { [weak self] in
            guard let syncStatus = self?.syncStatus, let layoutValue = self?.details?.layoutValue else { return nil }
            return DocumentSyncStatusData(syncStatus: syncStatus, layout: layoutValue)
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
}
