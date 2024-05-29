import Foundation
import Services
import Combine

struct DocumentSyncStatusData: Equatable {
    let syncStatus: SyncStatus
    let layout: DetailsLayout
}

extension BaseDocumentProtocol {
    
    var syncStatusDataPublisher: AnyPublisher<DocumentSyncStatusData, Never> {
        subscibeForDetails(objectId: objectId)
            .map { $0.layoutValue }
            .combineLatest(syncStatusPublisher)
            .map { DocumentSyncStatusData(syncStatus: $1, layout: $0) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
