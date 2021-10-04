import UIKit
import BlocksModels
import Combine
import AnytypeCore

protocol BlockActionHandlerProtocol {
    typealias Completion = (PackOfEvents) -> Void
    
    func upload(blockId: BlockId, filePath: String)
    func turnIntoPage(blockId: BlockId, completion: @escaping (BlockId?) -> ())
    
    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId, completion:  Completion?)
}

final class BlockActionHandler: BlockActionHandlerProtocol {
    private let documentId: String
    private let document: BaseDocumentProtocol
    private var subscriptions: [AnyCancellable] = []
    
    private let service: BlockActionServiceProtocol
    private let listService = BlockActionsServiceList()
    private let textBlockActionHandler: TextBlockActionHandler
    private let markupChanger: BlockMarkupChangerProtocol
    
    private weak var modelsHolder: ObjectContentViewModelsSharedHolder?
    
    init(
        documentId: String,
        modelsHolder: ObjectContentViewModelsSharedHolder,
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol
    ) {
        self.modelsHolder = modelsHolder
        self.documentId = documentId
        self.service = BlockActionService(documentId: documentId)
        self.document = document
        self.markupChanger = markupChanger
        
        self.textBlockActionHandler = TextBlockActionHandler(
            contextId: documentId,
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
    
    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId, completion:  Completion?) {
        service.configured { events in
            completion?(events)
        }
        
        switch action {
        case let .turnInto(textStyle):
            // TODO: why we need here turnInto only for text block?
            let textBlockContentType: BlockContent = .text(BlockText(contentType: textStyle))
            service.turnInto(blockId: blockId, type: textBlockContentType.type, shouldSetFocusOnUpdate: false)
        case let .setTextColor(color):
            setBlockColor(blockId: blockId, color: color, completion: completion)
        case let .setBackgroundColor(color):
            service.setBackgroundColor(blockId: blockId, color: color)
        case let .toggleWholeBlockMarkup(markup):
            markupChanger.toggleMarkup(markup, for: blockId)
        case let .toggleFontStyle(attrText, fontAttributes, range):
            markupChanger.toggleMarkup(fontAttributes, attributedText: attrText, for: blockId, in: range)
        case let .setAlignment(alignment):
            setAlignment(blockId: blockId, alignment: alignment, completion: completion)
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
            let response = listService.moveTo(contextId: documentId, blockId: blockId, targetId: targetId)
            response.flatMap { completion?(PackOfEvents(middlewareEvents: $0.messages)) }
        case let .textView(action: action, block: blockModel):
            switch action {
            case let .changeCaretPosition(selectedRange):
                document.userSession?.focus = .at(selectedRange)
            case let .changeTextStyle(string, styleAction, range):
                handleBlockAction(
                    .toggleFontStyle(string, styleAction, range),
                    blockId: blockId,
                    completion: completion
                )
            default:
                textBlockActionHandler.handlingTextViewAction(blockModel, action, completion: completion)
            }
        }
    }
    
    private func addBlock(blockId: BlockId, type: BlockContentType) {
        switch type {
        case .smartblock(.page):
            service.createPage(position: .bottom)
        default:
            guard let newBlock = BlockBuilder.createNewBlock(type: type),
                  let info = document.rootModel?.blocksContainer.model(id: blockId)?.information else {
                return
            }
            
            let shouldSetFocusOnUpdate = newBlock.content.isText ? true : false
            let position: BlockPosition = info.isTextAndEmpty ? .replace : .bottom
            
            service.add(info: newBlock, targetBlockId: info.id, position: position, shouldSetFocusOnUpdate: shouldSetFocusOnUpdate)
        }
    }
    
    
    // TODO: think how to manage duplicated coded in diff handlers
    // self.handlingKeyboardAction(block, .pressKey(.delete))
    private func delete(blockId: BlockId) {
        service.delete(blockId: blockId) { [weak self] value in
            guard let previousModel = self?.modelsHolder?.findModel(beforeBlockId: blockId) else {
                return .init(middlewareEvents: value.messages, localEvents: [])
            }
            let previousBlockId = previousModel.blockId
            return .init(middlewareEvents: value.messages, localEvents: [
                .setFocus(blockId: previousBlockId, position: .end)
            ])
        }
    }
}

private extension BlockActionHandler {
    func setBlockColor(blockId: BlockId, color: BlockColor, completion: Completion?) {
        let blockIds = [blockId]
        
        listService.setBlockColor(contextID: documentId, blockIds: blockIds, color: color.middleware)
            .sinkWithDefaultCompletion("setBlockColor") { value in
                let value = PackOfEvents(middlewareEvents: value.messages, localEvents: [])
                completion?(value)
            }
            .store(in: &self.subscriptions)
    }
    
    func setAlignment(
        blockId: BlockId,
        alignment: LayoutAlignment,
        completion: Completion?
    ) {
        let blockIds = [blockId]
        
        listService.setAlign(contextID: self.documentId, blockIds: blockIds, alignment: alignment)
            .sinkWithDefaultCompletion("setAlignment") { value in
                let value = PackOfEvents(middlewareEvents: value.messages, localEvents: [])
                completion?(value)
            }
            .store(in: &self.subscriptions)
    }
}
