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
    private weak var modelsHolder: SharedBlockViewModelsHolder?
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
        modelsHolder: SharedBlockViewModelsHolder,
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
            let textBlockContentType: BlockContent = .text(BlockText(contentType: textStyle))
            service.turnInto(blockId: blockId, type: textBlockContentType, shouldSetFocusOnUpdate: false)
        case let .setTextColor(color):
            setBlockColor(blockId: blockId, color: color, completion: completion)
        case let .setBackgroundColor(color):
            service.setBackgroundColor(blockId: blockId, color: color)
        case let .toggleFontStyle(fontAttributes, range):
            handleFontAction(blockId: blockId, range: range, fontAction: fontAttributes)
        case let .setAlignment(alignment):
            setAlignment(blockId: blockId, alignment: alignment, completion: completion)
        case let .setFields(contextID, fields):
            service.setFields(contextID: contextID, blockFields: fields)
        case .duplicate:
            service.duplicate(blockId: blockId)
        case .setLink(_):
            anytypeAssertionFailure("Action has not implemented yet \(String(describing: action))")
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
    
    private func turnIntoBlock(blockId: BlockId, type: BlockViewType) {
        switch type {
        case let .text(value): // Set Text Style
            let type: BlockContent
            switch value {
            case .text: type = .text(.empty())
            case .h1: type = .text(.init(contentType: .header))
            case .h2: type = .text(.init(contentType: .header2))
            case .h3: type = .text(.init(contentType: .header3))
            case .highlighted: type = .text(.init(contentType: .quote))
            }
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
            
        case let .list(value): // Set Text Style
            let type: BlockContent
            switch value {
            case .bulleted: type = .text(.init(contentType: .bulleted))
            case .checkbox: type = .text(.init(contentType: .checkbox))
            case .numbered: type = .text(.init(contentType: .numbered))
            case .toggle: type = .text(.init(contentType: .toggle))
            }
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
            
        case let .other(value): // Change divider style.
            let type: BlockContent
            switch value {
            case .lineDivider: type = .divider(.init(style: .line))
            case .dotsDivider: type = .divider(.init(style: .dots))
            case .code: return
            }
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
            
        case .objects(.page):
            let type: BlockContent = .smartblock(.init(style: .page))
            service.turnInto(blockId: blockId, type: type, shouldSetFocusOnUpdate: false)
            
        case .objects(.file):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.picture):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.video):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.bookmark):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.linkToObject):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        case .tool(_):
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        }
    }
    
    private func addBlock(blockId: BlockId, type: BlockViewType) {
        switch type {
        case .objects(.page):
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
    
    func handleFontAction(
        blockId: BlockId,
        range: NSRange,
        fontAction: BlockHandlerActionType.TextAttributesType
    ) {
        guard let info = document.rootModel?.blocksContainer.model(id: blockId)?.information,
              case let .text(textContentType) = info.content else { return }
        
        // if range length == 0 then apply to whole block
        if range.length == 0 {
            let subscription = textService.toggleWholeBlockMarkup(
                contextID: documentId,
                blockID: info.id,
                style: fontAction.wholeBlockMarkup)?
                .sinkWithDefaultCompletion("handleFontAction") { [weak self]  in
                    self?.document.handle(events: PackOfEvents(middlewareEvents: $0.messages))
                }
            subscription.flatMap { subscriptions.append($0) }
            return
        }
        let newAttributedString = NSMutableAttributedString(attributedString: textContentType.attributedText)
        
        switch fontAction {
        case .bold:
            applyNewStyle(
                trait: .traitBold,
                newString: newAttributedString,
                content: textContentType,
                range: range
            )
        case .italic:
            applyNewStyle(
                trait: .traitItalic,
                newString: newAttributedString,
                content: textContentType,
                range: range
            )
        case .strikethrough:
            if textContentType.attributedText.hasAttribute(.strikethroughStyle, at: range) {
                newAttributedString.removeAttribute(.strikethroughStyle, range: range)
            } else {
                newAttributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        case .keyboard:
            applyCode(
                content: textContentType,
                newString: newAttributedString,
                range: range
            )
        }
        store(
            newAttributedString,
            in: textContentType,
            id: info.id
        )
        document.eventHandler.handle(
            events: PackOfEvents(
                localEvents: [.setText(blockId: info.id, text: newAttributedString.string)]
            )
        )
    }
    
    private func applyCode(content: BlockText, newString: NSMutableAttributedString, range: NSRange) {
        guard let font = content.attributedText.attribute(
                .font,
                at: range.location,
                effectiveRange: nil) as? UIFont else {
            return
        }
        let resultFont = font.isCode ? content.contentType.uiFont : UIFont.code(of: font.pointSize)
        newString.addAttribute(.font, value: resultFont, range: range)
    }
    
    private func applyNewStyle(
        trait: UIFontDescriptor.SymbolicTraits,
        newString: NSMutableAttributedString,
        content: BlockText,
        range: NSRange
    )  {
        let hasTrait = content.attributedText.hasTrait(trait: trait, at: range)
        
        content.attributedText.enumerateAttribute(.font, in: range) { oldFont, range, _ in
            guard let oldFont = oldFont as? UIFont else { return }
            var symbolicTraits = oldFont.fontDescriptor.symbolicTraits
            
            if hasTrait {
                symbolicTraits.remove(trait)
            } else {
                symbolicTraits.insert(trait)
            }
            
            if let newFontDescriptor = oldFont.fontDescriptor.withSymbolicTraits(symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: oldFont.pointSize)
                newString.addAttributes([NSAttributedString.Key.font: newFont], range: range)
            }
        }
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
}
