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
    
    var objectDetails: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    // Looks like this code runs on main thread.
    // This operation should be done in `eventsListener.onUpdateReceive` closure
    // OR store flatten blocks instead of tree in `BlockContainer`
    var flattenBlocks: [BlockModelProtocol] {
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

    
    
    private func setup() {
        eventsListener.onUpdateReceive = { [weak self] update in
            guard update.hasUpdate else { return }
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.onUpdateReceive?(update)
            }
        }
        eventsListener.startListening()
    }
    
}
