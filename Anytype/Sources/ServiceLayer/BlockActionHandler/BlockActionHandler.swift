import UIKit
import BlocksModels
import Combine

protocol BlockActionHandlerProtocol {
    typealias Completion = (PackOfEvents) -> Void
    
    func handleBlockAction(_ action: BlockHandlerActionType, info: BlockInformation, completion:  Completion?)
    func upload(blockId: BlockId, filePath: String)
}

/// Actions from block
final class BlockActionHandler: BlockActionHandlerProtocol {
    private let service: BlockActionServiceProtocol
    private let listService = BlockActionsServiceList()
    private let textService = BlockActionsServiceText()
    private let documentId: String
    private var subscriptions: [AnyCancellable] = []
    private let modelsHolder: SharedBlockViewModelsHolder
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
    
    func handleBlockAction(_ action: BlockHandlerActionType, info: BlockInformation, completion:  Completion?) {
        service.configured { events in
            completion?(events)
        }
        
        switch action {
        case let .turnInto(textStyle):
            let textBlockContentType: BlockContent = .text(BlockText(contentType: textStyle))
            service.turnInto(blockId: info.id, type: textBlockContentType, shouldSetFocusOnUpdate: false)
        case let .setTextColor(color):
            setBlockColor(blockId: info.id, color: color, completion: completion)
        case let .setBackgroundColor(color):
            service.setBackgroundColor(blockId: info.id, color: color)
        case let .toggleFontStyle(fontAttributes, range):
            handleFontAction(info: info, range: range, fontAction: fontAttributes)
        case let .setAlignment(alignment):
            setAlignment(blockId: info.id, alignment: alignment, completion: completion)
        case let .setFields(contextID, fields):
            service.setFields(contextID: contextID, blockFields: fields)
        case .duplicate:
            service.duplicate(blockId: info.id)
        case .setLink(_):
            assertionFailure("Action has not implemented yet \(String(describing: action))")
        case .delete:
            delete(blockId: info.id)
        case let .addBlock(type):
            addBlock(info: info, type: type)
        case let .turnIntoBlock(type):
            turnIntoBlock(info: info, type: type)
        case let .fetch(url: url):
            service.bookmarkFetch(blockId: info.id, url: url.absoluteString)
        case .toggle:
            service.receivelocalEvents([.setToggled(blockId: info.id)])
        case .checkbox(selected: let selected):
            service.checked(blockId: info.id, newValue: selected)
        case let .showPage(pageId):
            router.showPage(with: pageId)
        case .createEmptyBlock(let parentId):
            service.addChild(info: BlockBuilder.createDefaultInformation(), parentBlockId: parentId)
        case let .textView(action: action, activeRecord: activeRecord):
            switch action {
            case .showMultiActionMenuAction:
                selectionHandler.selectionEnabled = true
            case let .changeCaretPosition(selectedRange):
                document.userSession?.focus = .at(selectedRange)
            case let .changeTextStyle(styleAction, range):
                handleBlockAction(
                    .toggleFontStyle(styleAction.asActionType, range),
                    info: info,
                    completion: completion
                )
            case let .changeTextForStruct(attributedText):
                textBlockActionHandler.handlingTextViewAction(activeRecord, action)
                completion.flatMap { completion in
                    completion(
                        PackOfEvents(
                            events: [],
                            localEvents: [.setText(blockId: info.id, text: attributedText.string)]
                        )
                    )    
                }
            default:
                textBlockActionHandler.handlingTextViewAction(activeRecord, action)
            }
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    private func turnIntoBlock(info: BlockInformation, type: BlockViewType) {
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
            service.turnInto(blockId: info.id, type: type, shouldSetFocusOnUpdate: false)
            
        case let .list(value): // Set Text Style
            let type: BlockContent
            switch value {
            case .bulleted: type = .text(.init(contentType: .bulleted))
            case .checkbox: type = .text(.init(contentType: .checkbox))
            case .numbered: type = .text(.init(contentType: .numbered))
            case .toggle: type = .text(.init(contentType: .toggle))
            }
            service.turnInto(blockId: info.id, type: type, shouldSetFocusOnUpdate: false)
            
        case let .other(value): // Change divider style.
            let type: BlockContent
            switch value {
            case .lineDivider: type = .divider(.init(style: .line))
            case .dotsDivider: type = .divider(.init(style: .dots))
            case .code: return
            }
            service.turnInto(blockId: info.id, type: type, shouldSetFocusOnUpdate: false)
            
        case .objects(.page):
            let type: BlockContent = .smartblock(.init(style: .page))
            service.turnInto(blockId: info.id, type: type, shouldSetFocusOnUpdate: false)
            
        case .objects(.file):
            assertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.picture):
            assertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.video):
            assertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.bookmark):
            assertionFailure("TurnInto for that style is not implemented \(type)")
        case .objects(.linkToObject):
            assertionFailure("TurnInto for that style is not implemented \(type)")
        case .tool(_):
            assertionFailure("TurnInto for that style is not implemented \(type)")
        }
    }
    
    private func addBlock(info: BlockInformation, type: BlockViewType) {
        switch type {
        case .objects(.page):
            service.createPage(position: .bottom)
        default:
            guard let newBlock = BlockBuilder.createInformation(blockType: type) else {
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
            guard let previousModel = self?.modelsHolder.findModel(beforeBlockId: blockId) else {
                return .init(events: value.messages, localEvents: [])
            }
            let previousBlockId = previousModel.blockId
            return .init(events: value.messages, localEvents: [
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
                let value = PackOfEvents(events: value.messages, localEvents: [])
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
                let value = PackOfEvents(events: value.messages, localEvents: [])
                completion?(value)
            }
            .store(in: &self.subscriptions)
    }
    
    func handleFontAction(
        info: BlockInformation,
        range: NSRange,
        fontAction: BlockHandlerActionType.TextAttributesType
    ) {
        guard case var .text(textContentType) = info.content else { return }
        var range = range
        
        // if range length == 0 then apply to whole block
        if range.length == 0 {
            range = NSRange(location: 0, length: textContentType.attributedText.length)
        }
        let newAttributedString = NSMutableAttributedString(attributedString: textContentType.attributedText)
        
        func applyNewStyle(trait: UIFontDescriptor.SymbolicTraits) {
            let hasTrait = textContentType.attributedText.hasTrait(trait: trait, at: range)
            
            textContentType.attributedText.enumerateAttribute(.font, in: range) { oldFont, range, shouldStop in
                guard let oldFont = oldFont as? UIFont else { return }
                var symbolicTraits = oldFont.fontDescriptor.symbolicTraits
                
                if hasTrait {
                    symbolicTraits.remove(trait)
                } else {
                    symbolicTraits.insert(trait)
                }
                
                if let newFontDescriptor = oldFont.fontDescriptor.withSymbolicTraits(symbolicTraits) {
                    let newFont = UIFont(descriptor: newFontDescriptor, size: oldFont.pointSize)
                    newAttributedString.addAttributes([NSAttributedString.Key.font: newFont], range: range)
                }
            }
            textContentType.attributedText = newAttributedString
            blockUpdater?.update(entry: info.id) { model in
                var model = model
                model.information.content = .text(textContentType)
                model.didChange()
            }
            
            textService.setText(
                contextID: self.documentId,
                blockID: info.id,
                attributedString: newAttributedString
            )
        }
        
        switch fontAction {
        case .bold:
            applyNewStyle(trait: .traitBold)
        case .italic:
            applyNewStyle(trait: .traitItalic)
        case .strikethrough:
            if textContentType.attributedText.hasAttribute(.strikethroughStyle, at: range) {
                newAttributedString.removeAttribute(.strikethroughStyle, range: range)
            } else {
                newAttributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            textContentType.attributedText = newAttributedString
            blockUpdater?.update(entry: info.id) { model in
                var model = model
                model.information.content = .text(textContentType)
                model.didChange()
            }
            textService.setText(
                contextID: self.documentId,
                blockID: info.id,
                attributedString: newAttributedString
            )
        case .keyboard:
            // TODO: Implement keyboard style https://app.clickup.com/t/fz48tc
            let keyboardColor = MiddlewareColor.grey
            let backgroundColor = info.backgroundColor
            let color = backgroundColor == keyboardColor ? MiddlewareColor.default : keyboardColor
            
            service.setBackgroundColor(blockId: info.id, color: color)
        }
    }
}
