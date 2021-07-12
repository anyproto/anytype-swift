import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()    
    
    func handleAction(_ action: BlockHandlerActionType, info: BlockInformation)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, info: BlockInformation)
    
    func upload(blockId: BlockId, filePath: String)
}

final class EditorActionHandler: EditorActionHandlerProtocol {
    let modelsHolder: SharedBlockViewModelsHolder
    let document: BaseDocumentProtocol
    let blockActionHandler: BlockActionHandler
    
    init(
        document: BaseDocumentProtocol,
        modelsHolder: SharedBlockViewModelsHolder,
        blockActionHandler: BlockActionHandler
    ) {
        self.document = document
        self.modelsHolder = modelsHolder
        self.blockActionHandler = blockActionHandler
    }
    
    func onEmptySpotTap() {
        guard let block = document.rootActiveModel?.blockModel, let parentId = document.documentId else {
            return
        }
        handleAction(.createEmptyBlock(parentId: parentId), info: block.information)
    }
    
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        guard let firstResponder = document.userSession?.firstResponder() else {
            assertionFailure("No first responder for action \(action)")
            return
        }
        
        handleAction(action, info: firstResponder.information)
    }
    
    func handleAction(_ action: BlockHandlerActionType, info: BlockInformation) {
        blockActionHandler.handleBlockAction(action, info: info) { [weak self] events in
            self?.process(events: events)
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        blockActionHandler.upload(blockId: blockId, filePath: filePath)
    }
    
    
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, info: BlockInformation) {
        blockActionHandler.handleBlockAction(action, info: info, completion: nil)
    }
    
    private func process(events: PackOfEvents) {
        events.localEvents.forEach { event in
            switch event {
            case let .setFocus(blockId, position):
                if let blockViewModel = modelsHolder.models.first(where: { $0.blockId == blockId }) as? TextBlockViewModel {
                    blockViewModel.set(focus: position)
                }
            default: return
            }
        }
        document.handle(events: events)
    }
}
