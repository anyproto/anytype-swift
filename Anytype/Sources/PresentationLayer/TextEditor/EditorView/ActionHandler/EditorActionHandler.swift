import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()    
    
    func handleAction(_ action: BlockHandlerActionType, model: BlockModelProtocol)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, model: BlockModelProtocol)
    
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
        handleAction(.createEmptyBlock(parentId: parentId), model: block)
    }
    
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        guard let firstResponder = document.userSession?.firstResponder() else {
            assertionFailure("No first responder for action \(action)")
            return
        }
        
        handleAction(action, model: firstResponder)
    }
    
    func handleAction(_ action: BlockHandlerActionType, model: BlockModelProtocol) {
        blockActionHandler.handleBlockAction(action, block: model) { [weak self] events in
            self?.process(events: events)
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        blockActionHandler.upload(blockId: blockId, filePath: filePath)
    }
    
    
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, model: BlockModelProtocol) {
        blockActionHandler.handleBlockAction(action, block: model, completion: nil)
    }
    
    private func process(events: PackOfEvents) {
        events.ourEvents.forEach { event in
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
