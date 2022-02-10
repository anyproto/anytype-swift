import BlocksModels
import Combine
import AnytypeCore
import Foundation

final class TextBlockActionHandler {
    
    private let service: BlockActionServiceProtocol
    private let contextId: String
    
    private weak var modelsHolder: EditorMainItemModelsHolder?

    init(
        contextId: String,
        service: BlockActionServiceProtocol,
        modelsHolder: EditorMainItemModelsHolder
    ) {
        self.service = service
        self.contextId = contextId
        self.modelsHolder = modelsHolder
    }
    
    func changeText(info: BlockInformation, text: NSAttributedString) {
        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            contextId: contextId,
            dataSourceUpdateEvents: [.setText(blockId: info.id, text: middlewareString)]
        ).send()

        service.setText(contextId: contextId, blockId: info.id, middlewareString: middlewareString)
    }

    func changeTextForced(info: BlockInformation, text: NSAttributedString) {
        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            contextId: contextId,
            localEvents: [.setText(blockId: info.id, text: middlewareString)]
        ).send()

        service.setTextForced(contextId: contextId, blockId: info.id, middlewareString: middlewareString)
    }

    func handleKeyboardAction(
        info: BlockInformation,
        action: CustomTextView.KeyboardAction,
        attributedText: NSAttributedString
    ) {
        switch action {
            // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
        case let .enterInsideContent(position):
            guard case let .text(text) = info.content else {
                anytypeAssertionFailure("Only text block may send keyboard action", domain: .textBlockActionHandler)
                return
            }
            service.split(
                info: info,
                position: position,
                newBlockContentType: text.contentType.contentTypeForSplit,
                attributedString: attributedText
            )

        case let .enterAtTheBeginingOfContent(payload):
            guard payload.isNotEmpty else {
                #warning("Fix it in TextView API.")
                /// If payload is empty, so, handle it as .enter ( or .enter at the end )
                handleKeyboardAction(info: info, action: .enterAtTheEndOfContent, attributedText: attributedText)
                return
            }

            guard case let .text(text) = info.content else {
                anytypeAssertionFailure("Not text block for enterAtTheBeginingOfContent", domain: .textBlockActionHandler)
                return
            }

            let type = text.contentType.contentTypeForSplit
            service.split(info: info, position: 0, newBlockContentType: type, attributedString: attributedText)

        case .enterAtTheEndOfContent:
            // BUSINESS LOGIC:
            // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
            switch info.content {
            case let .text(value) where value.contentType.isList && attributedText.string == "":
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

                            service.split(
                                info: info,
                                position: attributedText.string.count,
                                newBlockContentType: type,
                                attributedString: attributedText
                            )
                        }
                    default: return
                    }
                }
            }

        case .deleteAtTheBeginingOfContent:
            guard info.content.type != .text(.description) else { return }

            service.merge(secondBlockId: info.id)

        case .deleteOnEmptyContent:
            service.delete(blockId: info.id)
        }
    }
}

extension BlockText.Style {
    // We do want to create regular text block when splitting title block
    var contentTypeForSplit: BlockText.Style {
        self == .title ? .text : self
    }
}
