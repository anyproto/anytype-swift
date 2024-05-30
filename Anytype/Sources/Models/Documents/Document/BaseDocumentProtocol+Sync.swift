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
    
    func subscribeForDetails(objectId: String) -> AnyPublisher<ObjectDetails, Never> {
        subscibeFor(update: [.details(id: objectId)])
            .compactMap { [weak self] _ in
                self?.detailsStorage.get(id: objectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func subscribeForBlockInfo(blockId: String) -> AnyPublisher
    <BlockInformation, Never> {
        subscibeFor(update: [.block(blockId: objectId), .unhandled(blockId: blockId)])
            .compactMap { [weak self] _ in
                self?.infoContainer.get(id: blockId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var resetBlocksPublisher: AnyPublisher<Set<String>, Never> {
        syncDocPublisher
            .map { updates in
                let ids = updates.compactMap { update in
                    switch update {
                    case .block(let blockId):
                        return blockId
                    default:
                        return nil
                    }
                }
                return Set(ids)
            }
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    
    var childrenPublisher: AnyPublisher<[BlockInformation], Never> {
        subscibeFor(update: [.children])
            .compactMap { [weak self] _ in
                self?.children
            }
            .eraseToAnyPublisher()
    }
    
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> {
        subscribeForDetails(objectId: objectId)
    }
    
    var syncPublisher: AnyPublisher<Void, Never> {
        return syncDocPublisher
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}
