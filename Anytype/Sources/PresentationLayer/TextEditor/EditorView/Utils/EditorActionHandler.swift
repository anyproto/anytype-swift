import BlocksModels
import AnytypeCore

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()    
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    
    func upload(blockId: BlockId, filePath: String)
}

final class EditorActionHandler: EditorActionHandlerProtocol {
    let document: BaseDocumentProtocol
    let blockActionHandler: BlockActionHandler
    let eventProcessor: EventProcessor
    
    init(
        document: BaseDocumentProtocol,
        blockActionHandler: BlockActionHandler,
        eventProcessor: EventProcessor
    ) {
        self.document = document

        self.blockActionHandler = blockActionHandler
        self.eventProcessor = eventProcessor
    }
    
    func onEmptySpotTap() {
        guard let block = document.rootActiveModel, let parentId = document.documentId else {
            return
        }
        handleAction(.createEmptyBlock(parentId: parentId), blockId: block.information.id)
    }
    
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        guard let firstResponder = document.userSession?.firstResponder else {
            anytypeAssertionFailure("No first responder for action \(action)")
            return
        }
        
        handleAction(action, blockId: firstResponder.information.id)
    }
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId) {
        blockActionHandler.handleBlockAction(action, blockId: blockId) { [weak self] events in
            self?.eventProcessor.process(events: events)
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        self.eventProcessor.process(
            events: PackOfEvents(localEvent: .setLoadingState(blockId: blockId))
        )
        
        blockActionHandler.upload(blockId: blockId, filePath: filePath)
    }
}
