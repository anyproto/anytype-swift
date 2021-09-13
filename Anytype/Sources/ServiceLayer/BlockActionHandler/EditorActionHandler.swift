import BlocksModels
import AnytypeCore

enum ActionHandlerBlockIdSource {
    case firstResponder
    case provided(BlockId)
}

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()
    
    func upload(blockId: ActionHandlerBlockIdSource, filePath: String)
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
}

final class EditorActionHandler: EditorActionHandlerProtocol {
    let document: BaseDocumentProtocol
    let blockActionHandler: BlockActionHandlerProtocol
    let eventProcessor: EventProcessor
    
    init(
        document: BaseDocumentProtocol,
        blockActionHandler: BlockActionHandlerProtocol,
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
    
    func upload(blockId: ActionHandlerBlockIdSource, filePath: String) {
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        eventProcessor.process(
            events: PackOfEvents(localEvent: .setLoadingState(blockId: blockId))
        )
        
        blockActionHandler.upload(blockId: blockId, filePath: filePath)
    }
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        blockIdFromSource(.firstResponder).flatMap {
            handleAction(action, blockId: $0)
        }
    }

    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId) {
        blockActionHandler.handleBlockAction(action, blockId: blockId) { [weak self] events in
            self?.eventProcessor.process(events: events)
        }
    }
    
    // MARK: - Private
    
    private func blockIdFromSource(_ blockIdSource: ActionHandlerBlockIdSource) -> BlockId? {
        switch blockIdSource {
        case .firstResponder:
            guard let firstResponder = document.userSession?.firstResponder else {
                anytypeAssertionFailure("No first responder found")
                return nil
            }
            
            return firstResponder.information.id
        case .provided(let blockId):
            return blockId
        }
    }
}
