import BlocksModels
import AnytypeCore

enum ActionHandlerBlockIdSource {
    case firstResponder
    case provided(BlockId)
}

final class EditorActionHandler: EditorActionHandlerProtocol {
    private let fileUploadingDemon = FileUploadingDemon.shared
    private let document: BaseDocumentProtocol
    private let blockActionHandler: BlockActionHandlerProtocol
    private let eventProcessor: EventProcessor
    private let router: EditorRouterProtocol
    
    init(
        document: BaseDocumentProtocol,
        blockActionHandler: BlockActionHandlerProtocol,
        eventProcessor: EventProcessor,
        router: EditorRouterProtocol
    ) {
        self.document = document
        self.blockActionHandler = blockActionHandler
        self.eventProcessor = eventProcessor
        self.router = router
    }
    
    func onEmptySpotTap() {
        guard let block = document.rootActiveModel, let parentId = document.documentId else {
            return
        }
        handleAction(.createEmptyBlock(parentId: parentId), blockId: block.information.id)
    }
    
    func uploadMediaFile(
        itemProvider: NSItemProvider,
        type: MediaPickerContentType,
        blockId: ActionHandlerBlockIdSource
    ) {
        guard let objectId = document.documentId else { return }
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        eventProcessor.process(
            events: PackOfEvents(localEvent: .setLoadingState(blockId: blockId))
        )
        
        let operation = FileUploadingOperation(
            itemProvider: itemProvider,
            uploader: BlockMediaFileUploader(
                objectId: objectId,
                blockId: blockId,
                contentType: type
            )
        )
        
        fileUploadingDemon.addOperation(operation)
    }
    
    func uploadFileAt(localPath: String, blockId: ActionHandlerBlockIdSource) {
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        eventProcessor.process(
            events: PackOfEvents(localEvent: .setLoadingState(blockId: blockId))
        )
        
        blockActionHandler.upload(blockId: blockId, filePath: localPath)
    }
    
    func turnIntoPage(blockId: ActionHandlerBlockIdSource, completion: @escaping (BlockId?) -> ()) {
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        blockActionHandler.turnIntoPage(blockId: blockId, completion: completion)
    }
    
    func showPage(blockId: ActionHandlerBlockIdSource) {
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        router.showPage(with: blockId)
    }
    
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        blockIdFromSource(.firstResponder).flatMap {
            handleAction(action, blockId: $0)
        }
    }

    func handleActions(_ actions: [BlockHandlerActionType], blockId: BlockId) {
        actions.forEach { handleAction($0, blockId: blockId) }
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
