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
    private let pageServie: PageService
    private let router: EditorRouterProtocol
    
    init(
        document: BaseDocumentProtocol,
        blockActionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.document = document
        self.blockActionHandler = blockActionHandler
        self.router = router
        self.pageServie = PageService()
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
    
    func turnIntoPage(blockId: ActionHandlerBlockIdSource) -> BlockId? {
        guard let blockId = blockIdFromSource(blockId) else { return nil }
        
        return blockActionHandler.turnIntoPage(blockId: blockId)
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId? {
        guard let block = document.blocksContainer.model(id: targetId) else { return nil }
        if case .text(let blockText) = block.information.content, blockText.text.isEmpty {
            return blockActionHandler.createPage(targetId: targetId, type: type, position: .replace)
        }
        
        return blockActionHandler.createPage(targetId: targetId, type: type, position: .bottom)
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
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        blockActionHandler.setObjectTypeUrl(objectTypeUrl)
    }
    
    func changeCarretPosition(range: NSRange) {
        blockActionHandler.changeCaretPosition(range: range)
    }

    func showLinkToSearch(blockId: BlockId, attrText: NSAttributedString, range: NSRange) {
        router.showLinkToObject { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                self?.blockActionHandler.handleBlockAction(.setLinkToObject(linkBlockId: linkBlockId, attrText, range), blockId: blockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageServie.createPage(name: name) {
                    self?.blockActionHandler.handleBlockAction(.setLinkToObject(linkBlockId: linkBlockId, attrText, range), blockId: blockId)
                }
            case let .web(url):
                let link = URL(string: url)
                self?.blockActionHandler.handleBlockAction(.setLink(attrText, link, range), blockId: blockId)
            }
        }
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
