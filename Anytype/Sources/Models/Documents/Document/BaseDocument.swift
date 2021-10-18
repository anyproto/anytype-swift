import Foundation
import BlocksModels
import Combine
import AnytypeCore

private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

final class BaseDocument: BaseDocumentProtocol {
        
    var onUpdateReceive: ((EventsListenerUpdate) -> Void)?
    
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private let eventsListener: EventsListener
    
    let objectId: BlockId

    let blocksContainer: BlockContainerModelProtocol = BlockContainer()
    let detailsStorage: ObjectDetailsStorageProtocol = ObjectDetailsStorage()
        
    init(objectId: BlockId) {
        self.objectId = objectId
        
        self.eventsListener = EventsListener(
            objectId: objectId,
            blocksContainer: blocksContainer,
            detailsStorage: detailsStorage
        )
        
        setup()
    }
    
    deinit {
        blockActionsService.close(contextId: objectId, blockId: objectId)
    }

    // MARK: - BaseDocumentProtocol

    func open() {
        guard
            let result = blockActionsService.open(
                contextId: objectId,
                blockId: objectId
            )
        else { return }
        
        ObjectOpenEventProcessor.fillRootModelWithEventData(
            blocksContainer: blocksContainer,
            detailsStorage: detailsStorage,
            event: result
        )

        EventsBunch(objectId: objectId, middlewareEvents: result.messages).send()
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never> {
        // TODO: - details. implement
        .empty()
    }
    
    private func setup() {
        eventsListener.onUpdateReceive = { [weak self] update in
            guard update.hasUpdate else { return }
            guard let self = self else { return }
    
            // TODO: - details. what is it?
            if let rootModel = self.blocksContainer.model(id: self.objectId) {
                BlockFlattener.flattenIds(
                    root: rootModel,
                    in: self.blocksContainer,
                    options: .default
                )
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.onUpdateReceive?(update)
            }
            
//            let details = self.detailsStorage.get(id: self.objectId)
//            
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                
//                self.onUpdateReceive?(
//                    BaseDocumentUpdateResult(
//                        updates: update,
//                        details: details,
//                        models: self.models(from: update)
//                    )
//                )
//            }
        }
        eventsListener.startListening()
    }
    
    func getFlattenBlocks() -> [BlockModelProtocol] {
        guard
            let activeModel = blocksContainer.model(id: objectId)
        else {
            AnytypeLogger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(
            root: activeModel,
            in: blocksContainer,
            options: .default
        )
    }
    
//    private func models(from updates: EventsListenerUpdate) -> [BlockModelProtocol] {
//        switch updates {
//        case .general:
//            return getModels()
//        case .details, .blocks, .syncStatus:
//            return []
//        }
//    }
    
    /// Returns a flatten list of active models of document.
    /// - Returns: A list of active models.
//    private func getModels() -> [BlockModelProtocol] {
//        guard
//            let activeModel = blocksContainer.model(id: objectId)
//        else {
//            AnytypeLogger.create(.baseDocument).debug("getModels. Our document is not ready yet")
//            return []
//        }
//        return BlockFlattener.flatten(
//            root: activeModel,
//            in: blocksContainer,
//            options: .default
//        )
//    }

}
