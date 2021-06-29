import UIKit
import BlocksModels
import Combine

protocol BlockActionHandlerProtocol {
    typealias Completion = (PackOfEvents) -> Void
    
    func handleBlockAction(_ action: BlockHandlerActionType, block: BlockModelProtocol, completion:  Completion?)
    func upload(blockId: BlockId, filePath: String)
}

/// Actions from block
class BlockActionHandler: BlockActionHandlerProtocol {
    private let service: BlockActionServiceProtocol
    private let listService = BlockActionsServiceList()
    private let textService = BlockActionsServiceText()
    private let documentId: String
    private var subscriptions: [AnyCancellable] = []
    private weak var documentViewInteraction: DocumentViewInteraction?
    private let selectionHandler: EditorModuleSelectionHandlerProtocol
    private let document: BaseDocumentProtocol
    
    private let textBlockActionHandler: TextBlockActionHandler


    // MARK: - Lifecycle

    init?(
        documentId: String?,
        documentViewInteraction: DocumentViewInteraction?,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol
    ) {
        guard let documentId = documentId else { return nil }
        
        self.documentViewInteraction = documentViewInteraction
        self.documentId = documentId
        self.service = BlockActionService(documentId: documentId)
        self.selectionHandler = selectionHandler
        self.document = document
        
        self.textBlockActionHandler = TextBlockActionHandler(
            contextId: documentId,
            service: service,
            documentViewInteraction: documentViewInteraction,
            router: router
        )
    }

    // MARK: - Public methods

    func handleBlockAction(_ action: BlockHandlerActionType, block: BlockModelProtocol, completion:  Completion?) {
        service.configured { events in
            completion?(events)
        }

        switch action {
        case let .turnInto(textStyle):
            let textBlockContentType: BlockContent = .text(BlockText(contentType: textStyle))
            service.turnInto(block: block.information, type: textBlockContentType, shouldSetFocusOnUpdate: false)
        case let .setTextColor(color):
            setBlockColor(block: block.information, color: color, completion: completion)
        case let .setBackgroundColor(color):
            service.setBackgroundColor(block: block.information, color: color)
        case let .toggleFontStyle(fontAttributes, range):
            handleFontAction(for: block, range: range, fontAction: fontAttributes)
        case let .setAlignment(alignment):
            setAlignment(block: block.information, alignment: alignment, completion: completion)
        case .duplicate:
            service.duplicate(block: block.information)
        case .setLink(_):
            assertionFailure("Action has not implemented yet \(String(describing: action))")
        case .delete:
            delete(block: block)
        case let .addBlock(type):
            addBlock(block: block, type: type)
        case let .turnIntoBlock(type):
            turnIntoBlock(block: block, type: type)
        case let .fetch(url: url):
            service.bookmarkFetch(block: block.information, url: url.absoluteString)
        case .toggle:
            service.receiveOurEvents([.setToggled(blockId: block.information.id)])
        case .checkbox(selected: let selected):
            service.checked(blockId: block.information.id, newValue: selected)
        case .createEmptyBlock(let parentId):
            service.addChild(childBlock: BlockBuilder.createDefaultInformation(), parentBlockId: parentId)
        case let .textView(action: action, activeRecord: activeRecord):
            switch action {
            case .showMultiActionMenuAction:
                selectionHandler.selectionEnabled = true
            case let .changeCaretPosition(selectedRange):
                document.userSession?.setFocusAt(position: .at(selectedRange))
            case let .changeTextStyle(styleAction, range):
                handleBlockAction(.toggleFontStyle(styleAction.asActionType, range), block: block, completion: completion)
            default:
                textBlockActionHandler.handlingTextViewAction(activeRecord, action)
            }
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    private func turnIntoBlock(block: BlockModelProtocol, type: BlockViewType) {
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
           self.service.turnInto(block: block.information, type: type, shouldSetFocusOnUpdate: false)

       case let .list(value): // Set Text Style
           let type: BlockContent
           switch value {
           case .bulleted: type = .text(.init(contentType: .bulleted))
           case .checkbox: type = .text(.init(contentType: .checkbox))
           case .numbered: type = .text(.init(contentType: .numbered))
           case .toggle: type = .text(.init(contentType: .toggle))
           }
           self.service.turnInto(block: block.information, type: type, shouldSetFocusOnUpdate: false)

       case let .other(value): // Change divider style.
           let type: BlockContent
           switch value {
           case .lineDivider: type = .divider(.init(style: .line))
           case .dotsDivider: type = .divider(.init(style: .dots))
           case .code: return
           }
           self.service.turnInto(block: block.information, type: type, shouldSetFocusOnUpdate: false)

       case .objects(.page):
           let type: BlockContent = .smartblock(.init(style: .page))
           self.service.turnInto(block: block.information, type: type, shouldSetFocusOnUpdate: false)

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
    
    private func addBlock(block: BlockModelProtocol, type: BlockViewType) {
        switch type {
        case .objects(.page):
            service.createPage(afterBlock: block.information)
        default:
            guard let newBlock = BlockBuilder.createInformation(blockType: type) else {
                return
            }

            let shouldSetFocusOnUpdate = newBlock.content.isText ? true : false
            let position: BlockPosition = block.isTextAndEmpty ? .replace : .bottom

            service.add(newBlock: newBlock, targetBlockId: block.information.id, position: position, shouldSetFocusOnUpdate: shouldSetFocusOnUpdate)
        }
    }
    
    private func delete(block: BlockModelProtocol) {
        // TODO: think how to manage duplicated coded in diff handlers
        // self.handlingKeyboardAction(block, .pressKey(.delete))
        
        service.delete(block: block.information) { [weak self] value in
            guard let previousModel = self?.documentViewInteraction?.findModel(beforeBlockId: block.information.id) else {
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }
            let previousBlockId = previousModel.blockId
            return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                .setFocus(blockId: previousBlockId, position: .end)
            ])
        }
    }
}

private extension BlockActionHandler {
    func setBlockColor(block: BlockInformation, color: BlockColor, completion: Completion?) {
        guard let color = MiddlewareColorConverter.asString(color) else {
            assertionFailure("Wrong UIColor for setBlockColor command")
            return
        }
        let blockIds = [block.id]

        listService.setBlockColor(contextID: self.documentId, blockIds: blockIds, color: color)
            .sinkWithDefaultCompletion("setBlockColor") { value in
                let value = PackOfEvents(contextId: value.contextID, events: value.messages, ourEvents: [])
                completion?(value)
            }
            .store(in: &self.subscriptions)
    }

    func setAlignment(block: BlockInformation,
                      alignment: BlockInformationAlignment,
                      completion: Completion?) {
        let blockIds = [block.id]

        listService.setAlign(contextID: self.documentId, blockIds: blockIds, alignment: alignment)
            .sinkWithDefaultCompletion("setAlignment") { value in
                let value = PackOfEvents(contextId: value.contextID, events: value.messages, ourEvents: [])
                completion?(value)
            }
            .store(in: &self.subscriptions)
    }

    func handleFontAction(
        for block: BlockModelProtocol,
        range: NSRange,
        fontAction: BlockHandlerActionType.TextAttributesType
    ) {
        guard case var .text(textContentType) = block.information.content else { return }
        var range = range

        var newBlock = block

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
            newBlock.information.content = .text(textContentType)
            documentViewInteraction?.updateBlocks(with: [block.information.id])

            textService.setText(
                contextID: self.documentId,
                blockID: newBlock.information.id,
                attributedString: newAttributedString
            )
            .sink(receiveCompletion: {_ in }, receiveValue: {})
            .store(in: &self.subscriptions)
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
            newBlock.information.content = .text(textContentType)
            documentViewInteraction?.updateBlocks(with: [newBlock.information.id])
            textService.setText(
                contextID: self.documentId,
                blockID: newBlock.information.id,
                attributedString: newAttributedString
            )
            .sink(receiveCompletion: {_ in }, receiveValue: {})
            .store(in: &self.subscriptions)
        case .keyboard:
            // TODO: Implement keyboard style https://app.clickup.com/t/fz48tc
            let keyboardColor = MiddlewareColor.grey
            let backgroundColor = MiddlewareColorConverter.asMiddleware(name: newBlock.information.backgroundColor)
            let color = backgroundColor == keyboardColor ? MiddlewareColor.default : keyboardColor

            service.setBackgroundColor(block: newBlock.information, color: color)
        }
    }
}
