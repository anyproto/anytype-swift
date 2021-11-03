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
    
    private weak var modelsHolder: ObjectContentViewModelsSharedHolder?
    
    init(
        modelsHolder: ObjectContentViewModelsSharedHolder,
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

    // MARK: - Public methods
    
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        return service.turnIntoPage(blockId: blockId)
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId? {
        return service.createPage(targetId: targetId, type: type, position: position)
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        service.setObjectTypeUrl(objectTypeUrl)
    }
    
    func changeCaretPosition(range: NSRange) {
        UserSession.shared.focus.value = .at(range)
    }
    
    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId) {
        switch action {
        case let .turnInto(textStyle):
            // TODO: why we need here turnInto only for text block?
            let textBlockContentType = BlockContent.text(BlockText(contentType: textStyle))
            service.turnInto(blockId: blockId, type: textBlockContentType.type)
            
        case let .setTextColor(color):
            setBlockColor(blockId: blockId, color: color)
            
        case let .setBackgroundColor(color):
            service.setBackgroundColor(blockId: blockId, color: color)
            
        case let .toggleWholeBlockMarkup(markup):
            markupChanger.toggleMarkup(markup, for: blockId)
            
        case let .toggleFontStyle(attrText, fontAttributes, range):
            markupChanger.toggleMarkup(
                fontAttributes,
                attributedText: attrText,
                for: blockId,
                in: range
            )
            
        case let .setAlignment(alignment):
            setAlignment(blockId: blockId, alignment: alignment)
            
        case let .setFields(contextID, fields):
            service.setFields(contextID: contextID, blockFields: fields)
            
        case .duplicate:
            service.duplicate(blockId: blockId)
            
        case let .setLink(attrText, url, range):
            markupChanger.setLink(url, attributedText: attrText, for: blockId, in: range)

        case let .setLinkToObject(linkBlockId: linkBlockId, attrText, range):
            markupChanger.setLinkToObject(id: linkBlockId, attributedText: attrText, for: blockId, in: range)

        case .delete:
            delete(blockId: blockId)
            
        case let .addBlock(type):
            addBlock(blockId: blockId, type: type)
            
        case let .addLink(targetBlockId):
            service.add(
                info: BlockBuilder.createNewLink(targetBlockId: targetBlockId),
                targetBlockId: blockId,
                position: .bottom,
                shouldSetFocusOnUpdate: false
            )
            
        case let .turnIntoBlock(type):
            service.turnInto(blockId: blockId, type: type)
            
        case let .fetch(url: url):
            service.bookmarkFetch(blockId: blockId, url: url.absoluteString)
            
        case .toggle:
            service.receivelocalEvents([.setToggled(blockId: blockId)])
            
        case .checkbox(selected: let selected):
            service.checked(blockId: blockId, newValue: selected)
            
        case .createEmptyBlock(let parentId):
            service.addChild(
                info: BlockBuilder.createDefaultInformation(),
                parentBlockId: parentId
            )
            
        case .moveTo(targetId: let targetId):
            moveTo(targetId: targetId, blockId: blockId)
            
        case let .textView(action: action, info: info):
            switch action {
            case let .changeTextStyle(string, styleAction, range):
                handleBlockAction(
                    .toggleFontStyle(string, styleAction, range),
                    blockId: blockId
                )
                
            default:
                textBlockActionHandler.handlingTextViewAction(info, action)
            }
        }
    }
    
}

private extension BlockActionHandler {
    
    func setBlockColor(blockId: BlockId, color: BlockColor) {
        listService.setBlockColor(contextId: document.objectId, blockIds: [blockId], color: color.middleware)
    }
    
    func setAlignment(blockId: BlockId, alignment: LayoutAlignment) {
        listService.setAlign(contextId: document.objectId, blockIds: [blockId], alignment: alignment)
    }
    
    func delete(blockId: BlockId) {
        let previousModel = modelsHolder?.findModel(beforeBlockId: blockId)
        service.delete(blockId: blockId, previousBlockId: previousModel?.blockId)
    }
    
    func addBlock(blockId: BlockId, type: BlockContentType) {
        switch type {
        case .smartblock(.page):
            anytypeAssertionFailure("Use createPage func instead")
            _ = createPage(targetId: blockId, type: .bundled(.page), position: .bottom)
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
    
    func moveTo(targetId: BlockId, blockId: BlockId) {
        listService.moveTo(contextId: document.objectId, blockId: blockId, targetId: targetId)
    }
}
