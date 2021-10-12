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
    
    func turnIntoPage(blockId: BlockId, completion: @escaping (BlockId?) -> ()) {
        service.turnIntoPage(blockId: blockId, completion: completion)
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId) {
        switch action {
        case let .turnInto(textStyle):
            // TODO: why we need here turnInto only for text block?
            let textBlockContentType: BlockContent = .text(BlockText(contentType: textStyle))
            service.turnInto(blockId: blockId, type: textBlockContentType.type, shouldSetFocusOnUpdate: false)
        case let .setTextColor(color):
            setBlockColor(blockId: blockId, color: color)
        case let .setBackgroundColor(color):
            service.setBackgroundColor(blockId: blockId, color: color)
        case let .toggleWholeBlockMarkup(markup):
            markupChanger.toggleMarkup(markup, for: blockId)
        case let .toggleFontStyle(attrText, fontAttributes, range):
            markupChanger.toggleMarkup(fontAttributes, attributedText: attrText, for: blockId, in: range)
        case let .setAlignment(alignment):
            setAlignment(blockId: blockId, alignment: alignment)
        case let .setFields(contextID, fields):
            service.setFields(contextID: contextID, blockFields: fields)
        case .duplicate:
            service.duplicate(blockId: blockId)
        case let .setLink(attrText, url, range):
            markupChanger.setLink(url, attributedText: attrText, for: blockId, in: range)
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
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
        case let .fetch(url: url):
            service.bookmarkFetch(blockId: blockId, url: url.absoluteString)
        case .toggle:
            service.receivelocalEvents([.setToggled(blockId: blockId)])
        case .checkbox(selected: let selected):
            service.checked(blockId: blockId, newValue: selected)
        case .createEmptyBlock(let parentId):
            service.addChild(info: BlockBuilder.createDefaultInformation(), parentBlockId: parentId)
        case .moveTo(targetId: let targetId):
            let objectId = document.objectId
            let response = listService.moveTo(contextId: objectId, blockId: blockId, targetId: targetId)
            response.flatMap {
                NotificationCenter.default.post(
                    name: .middlewareEvent,
                    object: PackOfEvents(
                        objectId: objectId,
                        middlewareEvents: $0.messages
                    )
                )
            }
        case let .textView(action: action, block: blockModel):
            switch action {
            case let .changeCaretPosition(selectedRange):
                UserSession.shared.focus = .at(selectedRange)
            case let .changeTextStyle(string, styleAction, range):
                handleBlockAction(
                    .toggleFontStyle(string, styleAction, range),
                    blockId: blockId
                )
            default:
                textBlockActionHandler.handlingTextViewAction(blockModel, action)
            }
        }
    }
    
    private func addBlock(blockId: BlockId, type: BlockContentType) {
        switch type {
        case .smartblock(.page):
            service.createPage(position: .bottom)
        default:
            guard let newBlock = BlockBuilder.createNewBlock(type: type),
                  let info = document.rootModel.blocksContainer.model(id: blockId)?.information else {
                return
            }
            
            let shouldSetFocusOnUpdate = newBlock.content.isText ? true : false
            let position: BlockPosition = info.isTextAndEmpty ? .replace : .bottom
            
            service.add(info: newBlock, targetBlockId: info.id, position: position, shouldSetFocusOnUpdate: shouldSetFocusOnUpdate)
        }
    }
    
    
    private func delete(blockId: BlockId) {
        service.delete(blockId: blockId) { [weak self, document] value in
            guard
                let self = self,
                let previousModel = self.modelsHolder?.findModel(beforeBlockId: blockId)
            else {
                return PackOfEvents(
                    objectId: document.objectId,
                    middlewareEvents: value.messages
                )
            }
            let previousBlockId = previousModel.blockId
            return PackOfEvents(
                objectId: document.objectId,
                middlewareEvents: value.messages,
                localEvents: [
                    .setFocus(blockId: previousBlockId, position: .end)
                ]
            )
        }
    }
}

private extension BlockActionHandler {
    func setBlockColor(blockId: BlockId, color: BlockColor) {
        listService.setBlockColor(
            contextId: document.objectId,
            blockIds: [blockId],
            color: color.middleware
        )
            .flatMap {
                NotificationCenter.default.post(
                    name: .middlewareEvent,
                    object: PackOfEvents(
                        objectId: document.objectId,
                        middlewareEvents: $0.messages,
                        localEvents: []
                    )
                )
            }
    }
    
    func setAlignment(blockId: BlockId, alignment: LayoutAlignment) {
        listService.setAlign(
            contextId: document.objectId,
            blockIds: [blockId],
            alignment: alignment
        )
            .flatMap {
                NotificationCenter.default.post(
                    name: .middlewareEvent,
                    object: PackOfEvents(
                        objectId: document.objectId,
                        middlewareEvents: $0.messages,
                        localEvents: []
                    )
                )
            }
    }
}
