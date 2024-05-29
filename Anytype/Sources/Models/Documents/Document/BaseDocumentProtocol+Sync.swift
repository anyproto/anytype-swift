import Foundation
import Combine
import Services

extension BaseDocumentProtocol {
    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
        subscibeFor(update: [.syncStatus])
            .compactMap { [weak self] _ in
                self?.syncStatus
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func subscibeForDetails(objectId: String) -> AnyPublisher<ObjectDetails, Never> {
        subscibeFor(update: [.details(id: objectId)])
            .compactMap { [weak self] _ in
                self?.detailsStorage.get(id: objectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func subscribeForBlockInfo(blockId: String) -> AnyPublisher<BlockInformation, Never> {
        subscibeFor(update: [.block(blockId: objectId), .children(blockId: blockId), .unhandled(blockId: blockId)])
            .compactMap { [weak self] _ in
                self?.infoContainer.get(id: blockId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
