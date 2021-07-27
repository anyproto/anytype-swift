import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()    
    
    func handleAction(_ action: BlockHandlerActionType, info: BlockInformation)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, info: BlockInformation)
    
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
        handleAction(.createEmptyBlock(parentId: parentId), info: block.information)
    }
    
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        guard let firstResponder = document.userSession?.firstResponder else {
            assertionFailure("No first responder for action \(action)")
            return
        }
        
        handleAction(action, info: firstResponder.information)
    }
    
    func handleAction(_ action: BlockHandlerActionType, info: BlockInformation) {
        blockActionHandler.handleBlockAction(action, info: info) { [weak self] events in
            self?.eventProcessor.process(events: events)
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        self.eventProcessor.process(
            events: PackOfEvents(localEvent: .setLoadingState(blockId: blockId))
        )
        
        blockActionHandler.upload(blockId: blockId, filePath: filePath)
    }
    
    
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, info: BlockInformation) {
        blockActionHandler.handleBlockAction(action, info: info, completion: nil)
    }
}
