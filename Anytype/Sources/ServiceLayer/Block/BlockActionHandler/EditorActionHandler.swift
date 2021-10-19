import BlocksModels
import AnytypeCore

enum ActionHandlerBlockIdSource {
    case firstResponder
    case provided(BlockId)
}

final class EditorActionHandler: EditorActionHandlerProtocol {
    private let fileUploadingDemon = MediaFileUploadingDemon.shared
    private let document: BaseDocumentProtocol
    private let blockActionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    
    init(
        document: BaseDocumentProtocol,
        blockActionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.document = document
        self.blockActionHandler = blockActionHandler
        self.router = router
    }
    
    func onEmptySpotTap() {
        guard let block = document.blocksContainer.model(id: document.objectId) else {
            return
        }
        handleAction(
            .createEmptyBlock(parentId: document.objectId),
            blockId: block.information.id
        )
    }
    
    func uploadMediaFile(
        itemProvider: NSItemProvider,
        type: MediaPickerContentType,
        blockId: ActionHandlerBlockIdSource
    ) {
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        EventsBunch(
            objectId: document.objectId,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
        let operation = MediaFileUploadingOperation(
            itemProvider: itemProvider,
            worker: BlockMediaUploadingWorker(
                objectId: document.objectId,
                blockId: blockId,
                contentType: type
            )
        )
        fileUploadingDemon.addOperation(operation)
    }
    
    func uploadFileAt(localPath: String, blockId: ActionHandlerBlockIdSource) {
        guard let blockId = blockIdFromSource(blockId) else { return }
        
        EventsBunch(
            objectId: document.objectId,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
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

    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId) {
        blockActionHandler.handleBlockAction(action, blockId: blockId)
    }
    
    // MARK: - Private
    
    private func blockIdFromSource(_ blockIdSource: ActionHandlerBlockIdSource) -> BlockId? {
        switch blockIdSource {
        case .firstResponder:
            guard let firstResponder = UserSession.shared.firstResponderId.value else {
                anytypeAssertionFailure("No first responder found")
                return nil
            }
            
            return firstResponder
        case .provided(let blockId):
            return blockId
        }
    }
}
