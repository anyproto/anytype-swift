import Foundation
import Services
import Combine

struct DocumentSyncStatusData: Equatable {
    let syncStatus: SyncStatus
    let layout: DetailsLayout
}

extension BaseDocumentProtocol {
    
    private var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
        subscibeFor(update: [.syncStatus])
            .compactMap { [weak self] _ in
                self?.syncStatus
            }
            .eraseToAnyPublisher()
    }
    
    var syncStatusDataPublisher: AnyPublisher<DocumentSyncStatusData, Never> {
        subscribeForDetails(objectId: objectId)
            .map { $0.resolvedLayoutValue }
            .combineLatest(syncStatusPublisher)
            .map { DocumentSyncStatusData(syncStatus: $1, layout: $0) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
