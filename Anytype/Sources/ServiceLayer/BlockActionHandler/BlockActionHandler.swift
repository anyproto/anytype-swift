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
    private let textService = BlockActionsServiceText()
    private let documentId: String
    private var subscriptions: [AnyCancellable] = []
    private weak var modelsHolder: ObjectContentViewModelsSharedHolder?
    private let selectionHandler: EditorModuleSelectionHandlerProtocol
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let textBlockActionHandler: TextBlockActionHandler
    private lazy var blockUpdater: BlockUpdater? = {
        guard let container = document.rootModel else { return nil }
        return BlockUpdater(container)
    }()

    init(
        documentId: String,
        modelsHolder: ObjectContentViewModelsSharedHolder,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol
    ) {
        self.modelsHolder = modelsHolder
        self.documentId = documentId
        self.service = BlockActionService(documentId: documentId)
        self.selectionHandler = selectionHandler
        self.document = document
        self.router = router
        
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
        case let .toggleFontStyle(fontAttributes, range):
            handleFontAction(blockId: blockId, range: range, fontAction: fontAttributes)
        case let .setAlignment(alignment):
            setAlignment(blockId: blockId, alignment: alignment, completion: completion)
        case let .setFields(contextID, fields):
            service.setFields(contextID: contextID, blockFields: fields)
        case .duplicate:
            service.duplicate(blockId: blockId)
        case let .setLink(url, range):
            handleSetURL(url, range: range, blockId: blockId)
        case .delete:
            delete(blockId: blockId)
        case let .addBlock(type):
            addBlock(blockId: blockId, type: type)
        case let .turnIntoBlock(type):
            turnIntoBlock(blockId: blockId, type: type)
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
            case let .changeTextStyle(styleAction, range):
                handleBlockAction(
                    .toggleFontStyle(styleAction, range),
                    blockId: blockId,
                    completion: completion
                )
            case let .changeTextForStruct(attributedText):
                textBlockActionHandler.handlingTextViewAction(blockModel, action)
                completion.flatMap { completion in
                    completion(
                        PackOfEvents(
                            middlewareEvents: [],
                            localEvents: [.setText(blockId: blockId, text: attributedText.string)]
                        )
                    )    
                }
            default:
                textBlockActionHandler.handlingTextViewAction(blockModel, action)
            }
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    private func turnIntoBlock(blockId: BlockId, type: BlockContentType) {
        switch type {
        case .file(.file):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .file(.image):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .file(.video):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .bookmark(.page):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        default:
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
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
    
    func handleWholeBlockMarkupToggle(
        blockId: BlockId,
        markup: BlockHandlerActionType.TextAttributesType
    ) {
        guard let info = document.rootModel?.blocksContainer.model(id: blockId)?.information,
              case let .text(textContentType) = info.content else { return }
        handleFontAction(
            blockId: blockId,
            range: NSRange(
                location: 0,
                length: textContentType.attributedText.length
            ),
            fontAction: markup
        )
    }
    
    func handleFontAction(
        blockId: BlockId,
        range: NSRange,
        fontAction: BlockHandlerActionType.TextAttributesType
    ) {
        guard let info = document.rootModel?.blocksContainer.model(id: blockId)?.information,
              case let .text(textContentType) = info.content else { return }
        
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(
            for: textContentType.contentType
        )
        let markupCalculator = MarkupStateCalculator(
            attributedText: textContentType.attributedText,
            range: range,
            restrictions: restrictions,
            alignment: nil
        )
        let markupState = markupCalculator.state(for: fontAction)
        guard markupState != .disabled else { return }
        
        let newAttributedString = NSMutableAttributedString(
            attributedString: textContentType.attributedText
        )
        let marksModifier = MarkStyleModifier(
            attributedText: newAttributedString,
            defaultNonCodeFont: textContentType.contentType.uiFont
        )
        let shouldApplyMarkup = markupState == .notApplied
        switch fontAction {
        case .bold:
            marksModifier.apply(
                .bold(shouldApplyMarkup),
                range: range
            )
        case .italic:
            marksModifier.apply(
                .italic(shouldApplyMarkup),
                range: range
            )
        case .strikethrough:
            marksModifier.apply(
                .strikethrough(shouldApplyMarkup),
                range: range
            )
        case .keyboard:
            marksModifier.apply(
                .keyboard(shouldApplyMarkup),
                range: range
            )
        }
        store(
            marksModifier.attributedString,
            in: textContentType,
            id: info.id
        )
        document.eventHandler.handle(
            events: PackOfEvents(
                localEvents: [.setText(blockId: info.id, text: marksModifier.attributedString.string)]
            )
        )
    }
    
    private func store( _ attributedString: NSAttributedString, in content: BlockText, id: BlockId) {
        var content = content
        content.attributedText = attributedString
        blockUpdater?.update(entry: id) { model in
            var model = model
            model.information.content = .text(content)
        }
        textService.setText(
            contextID: documentId,
            blockID: id,
            attributedString: attributedString
        )
    }
    
    private func handleSetURL(_ url: URL?, range: NSRange, blockId: BlockId) {
        guard let model = document.rootModel?.blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("Can't find block with id: \(blockId)")
            return
        }
        guard case let .text(content) = model.information.content else {
            anytypeAssertionFailure("Unexpected block type \(model.information.content)")
            return
        }
        let restrictions = BlockRestrictionsFactory().makeRestrictions(for: .text(content))
        guard restrictions.canApplyOtherMarkup else { return }
        
        let modifier = MarkStyleModifier(
            attributedText: NSMutableAttributedString(attributedString: content.attributedText),
            defaultNonCodeFont: content.contentType.uiFont
        )
        modifier.apply(.link(url), range: range)
        store(
            modifier.attributedString,
            in: content,
            id: blockId
        )
        document.eventHandler.handle(
            events: PackOfEvents(
                localEvents: [.setText(blockId: blockId, text: modifier.attributedString.string)]
            )
        )
    }
}
