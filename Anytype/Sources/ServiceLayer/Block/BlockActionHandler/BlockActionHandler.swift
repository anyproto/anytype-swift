import UIKit
import BlocksModels
import Combine
import AnytypeCore

final class BlockActionHandler: BlockActionHandlerProtocol {
    private let document: BaseDocumentProtocol
    
    private let service: BlockActionServiceProtocol
    private let listService = BlockListService()
    private let textBlockActionHandler: TextBlockActionHandler
    private let markupChanger: BlockMarkupChangerProtocol
    
    private weak var modelsHolder: BlockViewModelsHolder?
    
    private let fileUploadingDemon = MediaFileUploadingDemon.shared
    
    init(
        modelsHolder: BlockViewModelsHolder,
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol
    ) {
        self.modelsHolder = modelsHolder
        self.service = BlockActionService(documentId: document.objectId)
        self.document = document
        self.markupChanger = markupChanger
        
        self.textBlockActionHandler = TextBlockActionHandler(
            contextId: document.objectId,
            service: service,
            modelsHolder: modelsHolder
        )
    }

    
    // MARK: - Service proxy
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        return service.turnIntoPage(blockId: blockId)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        service.turnInto(style, blockId: blockId)
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        service.setObjectTypeUrl(objectTypeUrl)
    }
    
    func setTextColor(_ color: BlockColor, blockId: BlockId) {
        listService.setBlockColor(contextId: document.objectId, blockIds: [blockId], color: color.middleware)
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockId: BlockId) {
        service.setBackgroundColor(blockId: blockId, color: color)
    }
    
    func duplicate(blockId: BlockId) {
        service.duplicate(blockId: blockId)
    }
    
    func setFields(_ fields: [BlockFields], blockId: BlockId) {
        service.setFields(contextID: document.objectId, blockFields: fields)
    }
    
    func fetch(url: URL, blockId: BlockId) {
        service.bookmarkFetch(blockId: blockId, url: url.absoluteString)
    }
    
    func checkbox(selected: Bool, blockId: BlockId) {
        service.checked(blockId: blockId, newValue: selected)
    }
    
    func toggle(blockId: BlockId) {
        EventsBunch(objectId: document.objectId, localEvents: [.setToggled(blockId: blockId)])
            .send()
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockId: BlockId) {
        listService.setAlign(contextId: document.objectId, blockIds: [blockId], alignment: alignment)
    }
    
    func delete(blockId: BlockId) {
        let previousModel = modelsHolder?.findModel(beforeBlockId: blockId)
        service.delete(blockId: blockId, previousBlockId: previousModel?.blockId)
    }
    
    func moveTo(targetId: BlockId, blockId: BlockId) {
        listService.moveTo(contextId: document.objectId, blockId: blockId, targetId: targetId)
    }
    
    func createEmptyBlock(parentId: BlockId?) {
        let parentId = parentId ?? document.objectId
        service.addChild(info: BlockInformation.emptyText, parentId: parentId)
    }
    
    func addLink(targetId: BlockId, blockId: BlockId) {
        service.add(
            info: BlockBuilder.createNewLink(targetBlockId: targetId),
            targetBlockId: blockId,
            position: .bottom,
            shouldSetFocusOnUpdate: false
        )
    }
    
    // MARK: - Markup changer proxy
    func toggleWholeBlockMarkup(_ markup: TextAttributesType, blockId: BlockId) {
        markupChanger.toggleMarkup(markup, for: blockId)
    }
    
    func changeTextStyle(_ attribute: TextAttributesType, range: NSRange, blockId: BlockId) {
        markupChanger.toggleMarkup(attribute, for: blockId, in: range)
    }
    
    func setLink(url: URL?, range: NSRange, blockId: BlockId) {
        markupChanger.setLink(url, for: blockId, in: range)
    }
    
    func setLinkToObject(linkBlockId: BlockId, range: NSRange, blockId: BlockId) {
        markupChanger.setLinkToObject(id: linkBlockId, for: blockId, in: range)
    }
    
    // MARK: - TextBlockActionHandler proxy
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation) {
        textBlockActionHandler.handleKeyboardAction(info: info, action: action)
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        textBlockActionHandler.changeText(info: info, text: text)
    }
    
    // MARK: - Public methods
    func changeCaretPosition(range: NSRange) {
        UserSession.shared.focus.value = .at(range)
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
        
        upload(blockId: blockId, filePath: localPath)
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId? {
        guard let block = document.blocksContainer.model(id: targetId) else { return nil }
        var position: BlockPosition
        if case .text(let blockText) = block.information.content, blockText.text.isEmpty {
            position = .replace
        } else {
            position = .bottom
        }
        
        return service.createPage(targetId: targetId, type: type, position: position)
    }

    func addBlock(_ type: BlockContentType, blockId: BlockId) {
        switch type {
        case .smartblock(.page):
            anytypeAssertionFailure("Use createPage func instead")
            _ = service.createPage(targetId: blockId, type: .bundled(.page), position: .bottom)
        default:
            guard
                let newBlock = BlockBuilder.createNewBlock(type: type),
                let info = document.blocksContainer.model(
                    id: blockId
                )?.information
            else {
                return
            }
            
            let shouldSetFocusOnUpdate = newBlock.content.isText ? true : false
            let position: BlockPosition = info.isTextAndEmpty ? .replace : .bottom
            
            service.add(
                info: newBlock,
                targetBlockId: info.id,
                position: position,
                shouldSetFocusOnUpdate: shouldSetFocusOnUpdate
            )
        }
    }
}
