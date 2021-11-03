import BlocksModels
import Combine
import AnytypeCore
import Foundation

final class TextBlockActionHandler {
    
    private let service: BlockActionServiceProtocol
    private let textService = TextService()
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

    func handlingTextViewAction(_ info: BlockInformation, _ action: CustomTextView.UserAction) {
        switch action {
        case let .keyboardAction(value):
            handlingKeyboardAction(info, value)
        case let .changeText(attributedText):
            handleChangeText(info, text: attributedText)
        case .changeTextStyle, .changeLink:
            anytypeAssertionFailure("We handle this update in `BlockActionHandler`")
        case .changeCaretPosition, .showPage:
            break
        case let .shouldChangeText(_, replacementText, mentionsHolder):
            mentionsHolder.removeMentionIfNeeded(text: replacementText)
        }
    }
    
    private func handleChangeText(_ info: BlockInformation, text: NSAttributedString) {
        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            objectId: contextId,
            localEvents: [.setText(blockId: info.id, text: middlewareString)]
        ).send()

        textService.setText(contextId: contextId, blockId: info.id, middlewareString: middlewareString)
    }

    private func handlingKeyboardAction(_ info: BlockInformation, _ action: CustomTextView.KeyboardAction) {
        switch action {
        // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
        case let .enterInsideContent(topString, bottomString):
            if let newBlock = BlockBuilder.createInformation(info: info, action: action, textPayload: bottomString ?? "") {
                if let oldText = topString {
                    guard case let .text(text) = info.content else {
                        anytypeAssertionFailure("Only text block may send keyboard action")
                        return
                    }
                    self.service.split(
                        info: info,
                        oldText: oldText,
                        newBlockContentType: text.contentType.contentTypeForSplit
                    )
                }
                else {
                    self.service.add(
                        info: newBlock, targetBlockId: info.id, position: .bottom, shouldSetFocusOnUpdate: true
                    )
                }
            }

        case let .enterAtTheBeginingOfContent(payload): // we should assure ourselves about type of block.
            /// TODO: Fix it in TextView API.
            /// If payload is empty, so, handle it as .enter ( or .enter at the end )
            if payload.isEmpty == true {
                self.handlingKeyboardAction(info, .enterAtTheEndOfContent)
                return
            }
            if let newBlock = BlockBuilder.createInformation(info: info, action: action, textPayload: payload) {
                if case let .text(text) = info.content {
                    self.service.split(
                        info: info,
                        oldText: "",
                        newBlockContentType: text.contentType.contentTypeForSplit
                    )
                }
                else {
                    self.service.add(info: newBlock, targetBlockId: info.id, position: .bottom, shouldSetFocusOnUpdate: true)
                }
            }

        case .enterAtTheEndOfContent:
            // BUSINESS LOGIC:
            // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
            switch info.content {
            case let .text(value) where value.contentType.isList && value.text == "":
                // Turn Into empty text block.
                if let newContentType = BlockBuilder.createContentType(info: info, action: action, textPayload: value.text) {
                    self.service.turnInto(blockId: info.id, type: newContentType.type)
                }
            default:
                if let newBlock = BlockBuilder.createInformation(info: info, action: action, textPayload: "") {
                    switch info.content {
                    case let .text(payload):
                        let isListAndNotToggle = payload.contentType.isListAndNotToggle
                        let isToggleAndOpen = payload.contentType == .toggle && UserSession.shared.isToggled(blockId: info.id)
                        // In case of return was tapped in list block (for toggle it should be open)
                        // and this block has children, we will insert new child block at the beginning
                        // of children list, otherwise we will create new block under current block
                        let childrenIds = info.childrenIds

                        switch (childrenIds.isEmpty, isToggleAndOpen, isListAndNotToggle) {
                        case (true, true, _):
                            self.service.addChild(info: newBlock, parentBlockId: info.id)
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
                                info: info,
                                oldText: payload.text,
                                newBlockContentType: newContentType
                            )
                        }
                    default: return
                    }
                }
            }

        case .deleteAtTheBeginingOfContent:
            guard info.content.type != .text(.description) else { return }
            guard let previousModel = modelsHolder?.findModel(beforeBlockId: info.id) else {
                anytypeAssertionFailure("""
                    We can't find previous block to focus on at command .delete
                    Block: \(info.id)
                    Moving to .delete command.
                    """
                )
                self.handlingKeyboardAction(info, .deleteOnEmptyContent)
                return
            }
            guard previousModel.content != .unsupported else { return }
            
            if textService.merge(contextId: contextId, firstBlockId: previousModel.blockId, secondBlockId: info.id) {
                setFocus(model: previousModel)
            }

        case .deleteOnEmptyContent:
            let blockId = info.id
            let previousModel = modelsHolder?.findModel(beforeBlockId: blockId)
            service.delete(blockId: blockId, previousBlockId: previousModel?.blockId)
        }
    }
    
    private func setFocus(model: BlockDataProvider) {
        var localEvents = [LocalEvent]()
        if case let .text(text) = model.information.content {
            let nsText = NSString(string: text.text)
            let range = NSRange(location: nsText.length, length: 0)
            localEvents.append(contentsOf: [
                .setFocus(blockId: model.blockId, position: .at(range))
            ])
        }
        EventsBunch(objectId: contextId, localEvents: localEvents).send()
    }
}

extension BlockText.Style {
    // We do want to create regular text block when splitting title block
    var contentTypeForSplit: BlockText.Style {
        self == .title ? .text : self
    }
}
