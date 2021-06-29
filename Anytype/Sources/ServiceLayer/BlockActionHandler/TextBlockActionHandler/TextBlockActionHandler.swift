import BlocksModels
import os
import Combine


final class TextBlockActionHandler {
    private let service: BlockActionServiceProtocol
    private var textService: BlockActionsServiceText = .init()
    private let contextId: String
    private let router: EditorRouterProtocol
    private let modelsHolder: SharedBlockViewModelsHolder

    init(
        contextId: String, service: BlockActionServiceProtocol, modelsHolder: SharedBlockViewModelsHolder, router: EditorRouterProtocol
    ) {
        self.service = service
        self.contextId = contextId
        self.modelsHolder = modelsHolder
        self.router = router
    }

    func handlingTextViewAction(_ block: BlockActiveRecordProtocol, _ action: CustomTextView.UserAction) {
        switch action {
        case let .keyboardAction(value):
            handlingKeyboardAction(block, value)
        case let .changeText(textView):
            handleChangeText(block, text: textView.attributedText)
        case .changeTextStyle:
            assertionFailure("We handle this update in `BlockActionHandler`")
        case .showMultiActionMenuAction, .showStyleMenu, .changeCaretPosition:
            break
        case let .shouldChangeText(range, replacementText, mentionsHolder):
            mentionsHolder.removeMentionIfNeeded(
                replacementRange: range,
                replacementText: replacementText
            )
        case let .showPage(pageId):
            router.showPage(with: pageId)
        }
    }
    
    private func handleChangeText(_ block: BlockActiveRecordProtocol, text: NSAttributedString) {
        guard case var .text(textContentType) = block.content else { return }
        var blockModel = block.blockModel

        let blockId = blockModel.information.id
        textContentType.attributedText = text
        blockModel.information.content = .text(textContentType)

        textService.setText(contextID: contextId, blockID: blockId, attributedString: text)
    }

    private func handlingKeyboardAction(_ block: BlockActiveRecordProtocol, _ action: CustomTextView.UserAction.KeyboardAction) {
        if DetailsKind(rawValue: block.blockId) == .name {
            switch action {
            case .enterAtTheEndOfContent, .enterInsideContent, .enterOnEmptyContent:
                let id = block.blockId
                let (blockId, _) = DetailsAsBlockConverter.IdentifierBuilder.asDetails(id)
                let block = block.container?.choose(by: blockId)
                let parentId = block?.blockId
                let information = BlockBuilder.createDefaultInformation()

                if let parentId = parentId {
                    if block?.childrenIds().isEmpty == true {
                        self.service.addChild(info: information, parentBlockId: parentId)
                    }
                    else {
                        let first = block?.childrenIds().first
                        service.add(info: information, targetBlockId: first ?? "", position: .top, shouldSetFocusOnUpdate: true)
                    }
                }

            default: return
            }
            return
        }
        
        switch action {
        // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
        case let .enterInsideContent(left, payload):
            if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                if let oldText = left {
                    guard case let .text(text) = block.content else {
                        assertionFailure("Only text block may send keyboard action")
                        return
                    }
                    self.service.split(
                        info: block.blockModel.information,
                        oldText: oldText,
                        newBlockContentType: text.contentType,
                        shouldSetFocusOnUpdate: true
                    )
                }
                else {
                    self.service.add(
                        info: newBlock, targetBlockId: block.blockId, position: .bottom, shouldSetFocusOnUpdate: true
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
                if !payload.isNil, case let .text(text) = block.content {
                    self.service.split(
                        info: block.blockModel.information,
                        oldText: "",
                        newBlockContentType: text.contentType,
                        shouldSetFocusOnUpdate: true
                    )
                }
                else {
                    self.service.add(info: newBlock, targetBlockId: block.blockId, position: .bottom, shouldSetFocusOnUpdate: true)
                }
            }

        case .enterAtTheEndOfContent:
            // BUSINESS LOGIC:
            // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
            switch block.content {
            case let .text(value) where value.contentType.isList && value.attributedText.string == "":
                // Turn Into empty text block.
                if let newContentType = BlockBuilder.createContentType(block: block, action: action, textPayload: value.attributedText.string) {
                    /// TODO: Add focus on this block.
                    self.service.turnInto(
                        blockId: block.blockModel.information.id,
                        type: newContentType,
                        shouldSetFocusOnUpdate: true
                    )
                }
            default:
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: "") {
                    /// TODO:
                    /// Uncomment when you are ready.
                    //                        self.service.add(newBlock: newBlock, afterBlockId: block.blockId, shouldSetFocusOnUpdate: true)
                    // "We should not use self.service.split here. Instead, we should self.service.add block. It is possible to swap them only after set focus total cleanup. Redo it."

                    switch block.content {
                    case let .text(payload):
                        let isListAndNotToggle = payload.contentType.isListAndNotToggle
                        let isToggleAndOpen = payload.contentType == .toggle && block.isToggled
                        // In case of return was tapped in list block (for toggle it should be open)
                        // and this block has children, we will insert new child block at the beginning
                        // of children list, otherwise we will create new block under current block
                        let childrenIds = block.childrenIds()
                        switch (childrenIds.isEmpty, isToggleAndOpen, isListAndNotToggle) {
                        case (true, true, _):
                            self.service.addChild(info: newBlock, parentBlockId: block.blockId)
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
                            let oldText = payload.attributedText.clearedFromMentionAtachmentsString()
                            self.service.split(
                                info: block.blockModel.information,
                                oldText: oldText,
                                newBlockContentType: newContentType,
                                shouldSetFocusOnUpdate: true
                            )
                        }
                    default: return
                    }

                }
            }

        case .deleteWithPayload(_):
            guard let previousModel = modelsHolder.findModel(beforeBlockId: block.blockId) else {
                assertionFailure("""
                    We can't find previous block to focus on at command .deleteWithPayload
                    Block: \(block.blockId)
                    Moving to .delete command.
                    """
                )
                self.handlingKeyboardAction(block, .deleteOnEmptyContent)
                return
            }
            let previousBlockId = previousModel.blockId
            
            var ourEvents = [OurEvent]()
            if case let .text(text) = previousModel.content {
                let range = NSRange(location: text.attributedText.length, length: 0)
                ourEvents.append(contentsOf: [
                    .setTextMerge(blockId: previousBlockId),
                    .setFocus(blockId: previousBlockId, position: .at(range))
                ])
            }

            service.merge(firstBlockId: previousModel.blockId, secondBlockId: block.blockId, ourEvents: ourEvents)
            break

        case .deleteOnEmptyContent:
            service.delete(blockId: block.blockModel.information.id) { [weak self] value in
                guard let previousModel = self?.modelsHolder.findModel(beforeBlockId: block.blockId) else {
                    assertionFailure(
                        "We can't find previous block to focus on at command .delete for block \(block.blockId)"
                    )
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }
                let previousBlockId = previousModel.blockId
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                    .setFocus(blockId: previousBlockId, position: .end)
                ])
            }
        }
    }
}
