import BlocksModels
import AnytypeCore

final class EditorActionHandler: EditorActionHandlerProtocol {
    private let fileUploadingDemon = MediaFileUploadingDemon.shared
    private let document: BaseDocumentProtocol
    private let handler: BlockActionHandlerProtocol
    private let pageServie: PageService
    private let router: EditorRouterProtocol
    
    init(
        document: BaseDocumentProtocol,
        blockActionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.document = document
        self.handler = blockActionHandler
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
    
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId) {
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
    
    func uploadFileAt(localPath: String, blockId: BlockId) {        
        EventsBunch(
            objectId: document.objectId,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
        handler.upload(blockId: blockId, filePath: localPath)
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId? {
        guard let block = document.blocksContainer.model(id: targetId) else { return nil }
        if case .text(let blockText) = block.information.content, blockText.text.isEmpty {
            return handler.createPage(targetId: targetId, type: type, position: .replace)
        }
        
        return handler.createPage(targetId: targetId, type: type, position: .bottom)
    }
    
    func showPage(blockId: BlockId) {
        router.showPage(with: blockId)
    }

    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId) {
        handler.handleBlockAction(action, blockId: blockId)
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        handler.setObjectTypeUrl(objectTypeUrl)
    }
    
    func changeCarretPosition(range: NSRange) {
        handler.changeCaretPosition(range: range)
    }
    
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation) {
        handler.handleKeyboardAction(action, info: info)
    }
    
    func changeTextStyle(text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange, blockId: BlockId) {
        handler.changeTextStyle(text: text, attribute: attribute, range: range, blockId: blockId)
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        handler.changeText(text, info: info)
    }

    func showLinkToSearch(blockId: BlockId, attrText: NSAttributedString, range: NSRange) {
        router.showLinkToObject { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                self?.handler.handleBlockAction(.setLinkToObject(linkBlockId: linkBlockId, attrText, range), blockId: blockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageServie.createPage(name: name) {
                    self?.handler.handleBlockAction(.setLinkToObject(linkBlockId: linkBlockId, attrText, range), blockId: blockId)
                }
            case let .web(url):
                let link = URL(string: url)
                self?.handler.handleBlockAction(.setLink(attrText, link, range), blockId: blockId)
            }
        }
    }
}
