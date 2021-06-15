import UIKit
import BlocksModels
import Combine

/// Actions from block
class BlockActionHandler {
    typealias Completion = (PackOfEvents) -> Void

    private let service: BlockActionServiceProtocol
    private let listService: BlockActionsServiceList = .init()
    private let textService: BlockActionsServiceText = .init()
    private let documentId: String
    private var subscriptions: [AnyCancellable] = []
    private weak var documentViewInteraction: DocumentViewInteraction?

    // MARK: - Lifecycle

    init?(documentId: String?, documentViewInteraction: DocumentViewInteraction?) {
        guard let documentId = documentId else { return nil }
        self.documentViewInteraction = documentViewInteraction
        self.documentId = documentId
        self.service = BlockActionService(documentId: documentId)
    }

    // MARK: - Public methods

    func handleBlockAction(_ action: ActionType, block: BlockModelProtocol, completion:  Completion?) {
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
        default:
            assertionFailure("Action has not implemented yet \(String(describing: action))")
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

    func handleFontAction(for block: BlockModelProtocol,
                          range: NSRange,
                          fontAction: ActionType.TextAttributesType) {
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
            self.documentViewInteraction?.updateBlocks(with: [block.information.id])

            self.textService.setText(contextID: self.documentId,
                                     blockID: newBlock.information.id,
                                     attributedString: newAttributedString)
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
            self.documentViewInteraction?.updateBlocks(with: [newBlock.information.id])
            self.textService.setText(contextID: self.documentId,
                                     blockID: newBlock.information.id,
                                     attributedString: newAttributedString)
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
