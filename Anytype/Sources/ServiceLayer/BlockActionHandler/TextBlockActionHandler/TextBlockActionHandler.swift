import BlocksModels
import os
import Combine
import AnytypeCore

final class TextBlockActionHandler {
    typealias Completion = (PackOfEvents) -> Void

    private let service: BlockActionServiceProtocol
    private var textService: BlockActionsServiceText = .init()
    private let contextId: String
    private weak var modelsHolder: ObjectContentViewModelsSharedHolder?

    init(
        contextId: String,
        service: BlockActionServiceProtocol,
        modelsHolder: ObjectContentViewModelsSharedHolder
    ) {
        self.service = service
        self.contextId = contextId
        self.modelsHolder = modelsHolder
    }

    func handlingTextViewAction(_ block: BlockModelProtocol, _ action: CustomTextView.UserAction, completion: Completion?) {
        switch action {
        case let .keyboardAction(value):
            handlingKeyboardAction(block, value)
        case let .changeText(attributedText):
            handleChangeText(block, text: attributedText, completion: completion)
        case .changeTextStyle, .changeLink:
            anytypeAssertionFailure("We handle this update in `BlockActionHandler`")
        case .showMultiActionMenuAction, .showStyleMenu, .changeCaretPosition, .showPage, .openURL:
            break
        case let .shouldChangeText(range, replacementText, mentionsHolder):
            mentionsHolder.removeMentionIfNeeded(
                replacementRange: range,
                replacementText: replacementText
            )
        }
    }
    
    private func handleChangeText(_ block: BlockModelProtocol, text: NSAttributedString, completion: Completion?) {
        guard case var .text(textContentType) = block.information.content else { return }
        var blockModel = block

        let blockId = blockModel.information.id
        blockModel.information.content = .text(textContentType)

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)
        textContentType.text = middlewareString.text
        textContentType.marks = middlewareString.marks

        textService.setText(contextID: contextId, blockID: blockId, middlewareString: middlewareString)

        completion?(
            PackOfEvents(localEvent:
                .setText(blockId: blockId, text: text.string)
            )
        )
    }

    private func handlingKeyboardAction(_ block: BlockModelProtocol, _ action: CustomTextView.UserAction.KeyboardAction) {
        if DetailsKind(rawValue: block.information.id) == .name {
            switch action {
            case .enterAtTheEndOfContent, .enterInsideContent, .enterOnEmptyContent:
                let id = block.information.id
                let (blockId, _) = DetailsAsBlockConverter.IdentifierBuilder.asDetails(id)
                let block = block.container?.model(id: blockId)
                let parentId = block?.information.id
                let information = BlockBuilder.createDefaultInformation()

                if let parentId = parentId {
                    if block?.information.childrenIds.isEmpty == true {
                        self.service.addChild(info: information, parentBlockId: parentId)
                    }
                    else {
                        let first = block?.information.childrenIds.first
                        service.add(info: information, targetBlockId: first ?? "", position: .top, shouldSetFocusOnUpdate: true)
                    }
                }

            default: return
            }
            return
        }
        
        switch action {
        // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
        case let .enterInsideContent(topString, bottomString):
            if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: bottomString ?? "") {
                if let oldText = topString {
                    guard case let .text(text) = block.information.content else {
                        anytypeAssertionFailure("Only text block may send keyboard action")
                        return
                    }
                    self.service.split(
                        info: block.information,
                        oldText: oldText,
                        newBlockContentType: text.contentType.contentTypeForSplit
                    )
                }
                else {
                    self.service.add(
                        info: newBlock, targetBlockId: block.information.id, position: .bottom, shouldSetFocusOnUpdate: true
                    )
                }
            }

        case let .enterOnEmptyContent(payload): // we should assure ourselves about type of block.
            /// TODO: Fix it in TextView API.
            /// If payload is empty, so, handle it as .enter ( or .enter at the end )
            if payload?.isEmpty == true {
                self.handlingKeyboardAction(block, .enterAtTheEndOfContent)
                return
            }
            if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                if !payload.isNil, case let .text(text) = block.information.content {
                    self.service.split(
                        info: block.information,
                        oldText: "",
                        newBlockContentType: text.contentType.contentTypeForSplit
                    )
                }
                else {
                    self.service.add(info: newBlock, targetBlockId: block.information.id, position: .bottom, shouldSetFocusOnUpdate: true)
                }
            }

        case .enterAtTheEndOfContent:
            // BUSINESS LOGIC:
            // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
            switch block.information.content {
            case let .text(value) where value.contentType.isList && value.text == "":
                // Turn Into empty text block.
                if let newContentType = BlockBuilder.createContentType(block: block, action: action, textPayload: value.text) {
                    /// TODO: Add focus on this block.
                    self.service.turnInto(
                        blockId: block.information.id,
                        type: newContentType.type,
                        shouldSetFocusOnUpdate: true
                    )
                }
            default:
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: "") {
                    switch block.information.content {
                    case let .text(payload):
                        let isListAndNotToggle = payload.contentType.isListAndNotToggle
                        let isToggleAndOpen = payload.contentType == .toggle && block.isToggled
                        // In case of return was tapped in list block (for toggle it should be open)
                        // and this block has children, we will insert new child block at the beginning
                        // of children list, otherwise we will create new block under current block
                        let childrenIds = block.information.childrenIds

                        switch (childrenIds.isEmpty, isToggleAndOpen, isListAndNotToggle) {
                        case (true, true, _):
                            self.service.addChild(info: newBlock, parentBlockId: block.information.id)
                        case (false, true, _), (false, _, true):
                            let firstChildId = childrenIds[0]
                            self.service.add(
                                info: newBlock,
                                targetBlockId: firstChildId,
                                position: .top,
                                shouldSetFocusOnUpdate: true
                            )
                        default:
                            let newContentType = payload.contentType.isList ? payload.contentType : .text

                            self.service.split(
                                info: block.information,
                                oldText: payload.text,
                                newBlockContentType: newContentType
                            )
                        }
                    default: return
                    }
                }
            }

        case .deleteWithPayload(_):
            guard block.information.content.type != .text(.description) else { return }
            guard let previousModel = modelsHolder?.findModel(beforeBlockId: block.information.id) else {
                anytypeAssertionFailure("""
                    We can't find previous block to focus on at command .deleteWithPayload
                    Block: \(block.information.id)
                    Moving to .delete command.
                    """
                )
                self.handlingKeyboardAction(block, .deleteOnEmptyContent)
                return
            }
            let previousBlockId = previousModel.blockId
            
            var localEvents = [LocalEvent]()
            if case let .text(text) = previousModel.information.content {
                let range = NSRange(location: text.text.count, length: 0)
                localEvents.append(contentsOf: [
                    .setTextMerge(blockId: previousBlockId),
                    .setFocus(blockId: previousBlockId, position: .at(range))
                ])
            }
            service.merge(firstBlockId: previousModel.blockId, secondBlockId: block.information.id, localEvents: localEvents)

        case .deleteOnEmptyContent:
            service.delete(blockId: block.information.id) { [weak self] value in
                guard let previousModel = self?.modelsHolder?.findModel(beforeBlockId: block.information.id) else {
                    anytypeAssertionFailure(
                        "We can't find previous block to focus on at command .delete for block \(block.information.id)"
                    )
                    return .init(middlewareEvents: value.messages, localEvents: [])
                }
                let previousBlockId = previousModel.blockId
                return .init(
                    middlewareEvents: value.messages,
                    localEvents: [
                        .setFocus(blockId: previousBlockId, position: .end)
                    ]
                )
            }
        }
    }
}

extension BlockText.Style {
    // We do want to create regular text block when splitting title block
    var contentTypeForSplit: BlockText.Style {
        self == .title ? .text : self
    }
}
