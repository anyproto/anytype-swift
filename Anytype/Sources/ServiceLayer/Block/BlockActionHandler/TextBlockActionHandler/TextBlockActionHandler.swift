import BlocksModels
import Combine
import AnytypeCore
import Foundation

final class TextBlockActionHandler {
    
    private let service: BlockActionServiceProtocol
    private let textService = TextService()
    private let contextId: String
    
    private weak var modelsHolder: BlockViewModelsHolder?

    init(
        contextId: String,
        service: BlockActionServiceProtocol,
        modelsHolder: BlockViewModelsHolder
    ) {
        self.service = service
        self.contextId = contextId
        self.modelsHolder = modelsHolder
    }
    
    func changeText(info: BlockInformation, text: NSAttributedString) {
        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            objectId: contextId,
            localEvents: [.setText(blockId: info.id, text: middlewareString)]
        ).send()

        textService.setText(contextId: contextId, blockId: info.id, middlewareString: middlewareString)
    }

    func handleKeyboardAction(info: BlockInformation, action: CustomTextView.KeyboardAction) {
        switch action {
        // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
        case let .enterInsideContent(position):
            guard case let .text(text) = info.content else {
                anytypeAssertionFailure("Only text block may send keyboard action")
                return
            }
            service.split(info: info, position: position, newBlockContentType: text.contentType.contentTypeForSplit)

        case let .enterAtTheBeginingOfContent(payload):
            guard payload.isNotEmpty else {
                /// TODO: Fix it in TextView API.
                /// If payload is empty, so, handle it as .enter ( or .enter at the end )
                handleKeyboardAction(info: info, action: .enterAtTheEndOfContent)
                return
            }
            
            guard case let .text(text) = info.content else {
                anytypeAssertionFailure("Not text block for enterAtTheBeginingOfContent")
                return
            }
            
            let type = text.contentType.contentTypeForSplit
            service.split(info: info, position: 0, newBlockContentType: type)

        case .enterAtTheEndOfContent:
            // BUSINESS LOGIC:
            // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
            switch info.content {
            case let .text(value) where value.contentType.isList && value.text == "":
                // Turn Into empty text block.
                BlockBuilder.textStyle(info: info).flatMap { style in
                    self.service.turnInto(style, blockId: info.id)
                }
            default:
                if let newBlock = BlockBuilder.createInformation(info: info) {
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
                            service.addChild(info: newBlock, parentId: info.id)
                        case (false, true, _), (false, _, true):
                            let firstChildId = childrenIds[0]
                            service.add(
                                info: newBlock,
                                targetBlockId: firstChildId,
                                position: .top,
                                shouldSetFocusOnUpdate: true
                            )
                        default:
                            let type = payload.contentType.isList ? payload.contentType : .text
                            service.split(info: info, position: payload.text.count, newBlockContentType: type)
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
                handleKeyboardAction(info: info, action: .deleteOnEmptyContent)
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
