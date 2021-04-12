import BlocksModels
import os
import Combine


final class TextBlockActionHandler {
    typealias ActionsPayload = BlocksViews.Base.ViewModel.ActionsPayload
    typealias DetailsInspector = TopLevel.BlockUtilities.DetailsInspector

    private var subscriptions: Set<AnyCancellable> = []
    private let service: BlockActionService
    private var textService: BlockActionsServiceText = .init()
    private let contextId: String
    private var indexWalker: LinearIndexWalker?

    init(contextId: String, service: BlockActionService, indexWalker: LinearIndexWalker?) {
        self.service = service
        self.contextId = contextId
        self.indexWalker = indexWalker
    }

    func handlingTextViewAction(_ block: BlockActiveRecordModelProtocol, _ action: TextView.UserAction) {
        switch action {
        case let .keyboardAction(value): self.handlingKeyboardAction(block, value)
        case let .inputAction(value): self.handlingInputAction(block, value)
        case .showMultiActionMenuAction:
            break
        default:
            assertionFailure("Unexpected: \(action)")
        }
    }

    func model(beforeModel: BlockActiveRecordModelProtocol, includeParent: Bool) -> BlockActiveRecordModelProtocol? {
        //        TopLevel.BlockUtilities.IndexWalker.model(beforeModel: beforeModel, includeParent: includeParent)
        self.indexWalker?.renew()
        return self.indexWalker?.model(beforeModel: beforeModel, includeParent: includeParent)
    }

    private func handlingInputAction(_ block: BlockActiveRecordModelProtocol, _ action: TextView.UserAction.InputAction) {
        guard case var .text(textContentType) = block.blockModel.information.content else { return }
        var blockModel = block.blockModel

        switch action {
        case let .changeText(attributedText):
            let blockId = blockModel.information.id
            textContentType.attributedText = attributedText
            blockModel.information.content = .text(textContentType)

            self.textService.setText(contextID: self.contextId, blockID: blockId, attributedString: attributedText)
                .sink(receiveCompletion: { value in
                    switch value {
                    case .finished: return
                    case let .failure(error):
                        assertionFailure("""
                            TextBlocksViews setBlockText error has occured.
                            \(error)
                            ParentId: \(blockModel.parent)
                            BlockId: \(blockModel.information.id)
                            """
                        )
                    }
                }, receiveValue: { _ in }).store(in: &self.subscriptions)
        }
    }

    private func handlingKeyboardAction(_ block: BlockActiveRecordModelProtocol, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            if DetailsInspector.kind(of: block.blockModel.information.id) == .title {
                switch keyAction {
                case .enterAtTheEndOfContent, .enterInsideContent, .enterOnEmptyContent:
                    let id = block.blockModel.information.id
                    let (blockId, _) = TopLevel.InformationUtilitiesDetailsBlockConverter.IdentifierBuilder.asDetails(id)
                    let block = block.container?.choose(by: blockId)
                    let parentId = block?.blockModel.information.id

                    if let information = BlockBuilder.createDefaultInformation(), let parentId = parentId {
                        if block?.childrenIds().isEmpty == true {
                            self.service.addChild(childBlock: information, parentBlockId: parentId)
                        }
                        else {
                            let first = block?.childrenIds().first
                            self.service.add(newBlock: information, afterBlockId: first ?? "", position: .top, shouldSetFocusOnUpdate: true)
                        }
                    }

                default: return
                }
                return
            }
            switch keyAction {
            // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
            case let .enterInsideContent(left, payload):
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if let oldText = left {
                        guard case let .text(text) = block.blockModel.information.content else {
                            assertionFailure("Only text block may send keyboard action")
                            return
                        }
                        self.service.split(block: block.blockModel.information,
                                           oldText: oldText,
                                           newBlockContentType: text.contentType,
                                           shouldSetFocusOnUpdate: true)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                    }
                }

            case let .enterOnEmptyContent(payload): // we should assure ourselves about type of block.
                /// TODO: Fix it in TextView API.
                /// If payload is empty, so, handle it as .enter ( or .enter at the end )
                if payload?.isEmpty == true {
                    self.handlingKeyboardAction(block, .pressKey(.enterAtTheEndOfContent))
                    return
                }
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if payload != nil, case let .text(text) = block.blockModel.information.content {
                        self.service.split(block: block.blockModel.information,
                                           oldText: "",
                                           newBlockContentType: text.contentType,
                                           shouldSetFocusOnUpdate: true)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                    }
                }

            case .enterAtTheEndOfContent:
                // BUSINESS LOGIC:
                // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
                switch block.blockModel.information.content {
                case let .text(value) where value.contentType.isList && value.attributedText.string == "":
                    // Turn Into empty text block.
                    if let newContentType = BlockBuilder.createContentType(block: block, action: action, textPayload: value.attributedText.string) {
                        /// TODO: Add focus on this block.
                        self.service.turnInto(block: block.blockModel.information, type: newContentType, shouldSetFocusOnUpdate: true)
                    }
                default:
                    if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: "") {
                        /// TODO:
                        /// Uncomment when you are ready.
                        //                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                        // "We should not use self.service.split here. Instead, we should self.service.add block. It is possible to swap them only after set focus total cleanup. Redo it."

                        switch block.blockModel.information.content {
                        case let .text(payload):
                            let isListAndNotToggle = payload.contentType.isListAndNotToggle
                            let isToggleAndOpen = payload.contentType == .toggle && block.isToggled
                            // In case of return was tapped in list block (for toggle it should be open)
                            // and this block has children, we will insert new child block at the beginning
                            // of children list, otherwise we will create new block under current block
                            let childrenIds = block.childrenIds()
                            switch (childrenIds.isEmpty, isToggleAndOpen, isListAndNotToggle) {
                            case (true, true, _):
                                self.service.addChild(childBlock: newBlock,
                                                      parentBlockId: block.blockModel.information.id)
                            case (false, true, _), (false, _, true):
                                let firstChildId = childrenIds[0]
                                self.service.add(newBlock: newBlock,
                                                 afterBlockId: firstChildId,
                                                 position: .top,
                                                 shouldSetFocusOnUpdate: true)
                            default:
                                let newContentType = payload.contentType.isList ? payload.contentType : .text
                                let oldText = payload.attributedText.string
                                self.service.split(block: block.blockModel.information,
                                                   oldText: oldText,
                                                   newBlockContentType: newContentType,
                                                   shouldSetFocusOnUpdate: true)
                            }
                        default: return
                        }

                    }
                }

            case .deleteWithPayload(_):
                // TODO: Add Index Walker
                // Add get previous block

                guard let previousModel = self.model(beforeModel: block, includeParent: true) else {
                    assertionFailure("""
                        We can't find previous block to focus on at command .deleteWithPayload
                        Block: \(block.blockModel.information.id)
                        Moving to .delete command.
                        """
                    )
                    self.handlingKeyboardAction(block, .pressKey(.deleteOnEmptyContent))
                    return
                }

                let previousBlockId = previousModel.blockModel.information.id
                let position: EventListening.OurEvent.Focus.Payload.Position

                switch previousModel.blockModel.information.content {
                case let .text(value):
                    let length = value.attributedText.length
                    position = .at(length)
                default: position = .end
                }

                self.service.merge(firstBlock: previousModel.blockModel.information, secondBlock: block.blockModel.information) { value in
                    .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setTextMerge(.init(payload: .init(blockId: previousBlockId))),
                        .setFocus(.init(payload: .init(blockId: previousBlockId, position: position)))
                    ])
                }
                break

            case .deleteOnEmptyContent:
                self.service.delete(block: block.blockModel.information) { value in
                    guard let previousModel = self.model(beforeModel: block, includeParent: true) else {
                        assertionFailure(
                            "We can't find previous block to focus on at command .delete for block \(block.blockModel.information.id)"
                        )
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    let previousBlockId = previousModel.blockModel.information.id
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setFocus(.init(payload: .init(blockId: previousBlockId, position: .end)))
                    ])
                }
            }
        }
    }
}
