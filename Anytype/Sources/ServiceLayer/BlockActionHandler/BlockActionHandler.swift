import UIKit
import BlocksModels
import Combine
import AnytypeCore

protocol BlockActionHandlerProtocol {
    typealias Completion = (PackOfEvents) -> Void
    
    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId, completion:  Completion?)
    func upload(blockId: BlockId, filePath: String)
}

/// Actions from block
final class BlockActionHandler: BlockActionHandlerProtocol {
    private let service: BlockActionServiceProtocol
    private let listService = BlockActionsServiceList()
    private let documentId: String
    private var subscriptions: [AnyCancellable] = []
    private weak var modelsHolder: ObjectContentViewModelsSharedHolder?
    private let selectionHandler: EditorModuleSelectionHandlerProtocol
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let textBlockActionHandler: TextBlockActionHandler
    private let markupChanger: BlockMarkupChangerProtocol

    init(
        documentId: String,
        modelsHolder: ObjectContentViewModelsSharedHolder,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        markupChanger: BlockMarkupChangerProtocol
    ) {
        self.modelsHolder = modelsHolder
        self.documentId = documentId
        self.service = BlockActionService(documentId: documentId)
        self.selectionHandler = selectionHandler
        self.document = document
        self.router = router
        self.markupChanger = markupChanger
        
        self.textBlockActionHandler = TextBlockActionHandler(
            contextId: documentId,
            service: service,
            modelsHolder: modelsHolder
        )
    }

    // MARK: - Public methods
    
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
            handleWholeBlockMarkupToggle(blockId: blockId, markup: markup)
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
        case let .turnIntoBlock(type):
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
        case let .fetch(url: url):
            service.bookmarkFetch(blockId: blockId, url: url.absoluteString)
        case .toggle:
            service.receivelocalEvents([.setToggled(blockId: blockId)])
        case .checkbox(selected: let selected):
            service.checked(blockId: blockId, newValue: selected)
        case let .showPage(pageId):
            router.showPage(with: pageId)
        case .createEmptyBlock(let parentId):
            service.addChild(info: BlockBuilder.createDefaultInformation(), parentBlockId: parentId)
        case let .textView(action: action, block: blockModel):
            switch action {
            case .showMultiActionMenuAction:
                selectionHandler.selectionEnabled = true
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
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
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
    
    func handleWholeBlockMarkupToggle(
        blockId: BlockId,
        markup: BlockHandlerActionType.TextAttributesType
    ) {
        guard let info = document.rootModel?.blocksContainer.model(id: blockId)?.information,
              case let .text(textContentType) = info.content else { return }
        let range = NSRange(
            location: 0,
            length: textContentType.text.count
        )
        let anytypeText = AttributedTextConverter.asModel(text: textContentType.text,
                                                          marks: textContentType.marks,
                                                          style: textContentType.contentType)
        markupChanger.toggleMarkup(
            markup,
            attributedText: anytypeText.attrString,
            for: blockId,
            in: range
        )
    }
}
