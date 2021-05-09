import UIKit
import Combine
import OSLog
import BlocksModels


final class MarksPaneBlockActionHandler {
    typealias ActionsPayload = BaseBlockViewModel.ActionsPayload
    typealias ActionsPayloadMarksPane = ActionsPayload.MarksPaneHolder.Action
    typealias Conversion = (ServiceSuccess) -> (EventListening.PackOfEvents)
    
    private let service: BlockActionService
    private var textService: BlockActionsServiceText = .init()
    private let listService: BlockActionsServiceList = .init()
    private let contextId: String
    private var subscriptions: [AnyCancellable] = []
    private weak var subject: PassthroughSubject<BlockActionService.Reaction?, Never>?
    private weak var documentViewInteraction: DocumentViewInteraction?

    init(documentViewInteraction: DocumentViewInteraction?, service: BlockActionService, contextId: String, subject: PassthroughSubject<BlockActionService.Reaction?, Never>) {
        self.documentViewInteraction = documentViewInteraction
        self.service = service
        self.contextId = contextId
        self.subject = subject
    }
    
    func handlingMarksPaneAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionsPayloadMarksPane) {
        switch action {
        case let .style(range, styleAction):
            switch styleAction {
            case let .alignment(alignmentAction):
                self.setAlignment(block: block.blockModel.information, alignment: alignmentAction)
            case let .fontStyle(fontAction):
                self.handleFontAction(for: block, range: range, fontAction: fontAction)
            }
        case let .textColor(_, colorAction):
            switch colorAction {
            case let .setColor(color):
                self.setBlockColor(block: block.blockModel.information, color: color)
            }
        case let .backgroundColor(_, action):
            switch action {
            case let .setColor(value):
                self.service.setBackgroundColor(block: block.blockModel.information, color: value)
            }
        }
    }
}

private extension MarksPaneBlockActionHandler {

    func setBlockColor(block: BlockInformation.InformationModel, color: UIColor) {
        // Important: we don't send command if color is wrong
        guard let color = MiddlewareModelsModule.Parsers.Text.Color.Converter.asMiddleware(color, background: false) else {
            assertionFailure("Wrong UIColor for setBlockColor command")
            return
        }
        let blockIds = [block.id]

        self.listService.setBlockColor(contextID: self.contextId, blockIds: blockIds, color: color)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("setBlockColor: \(error.localizedDescription)")
                }
            }) { [weak self] (value) in
                let value = EventListening.PackOfEvents(contextId: value.contextID, events: value.messages, ourEvents: [])
                self?.subject?.send(.shouldHandleEvent(.init(actionType: nil, events: value)))
            }
            .store(in: &self.subscriptions)
    }

    func setAlignment(block: BlockInformation.InformationModel, alignment: MarksPane.Panes.StylePane.Alignment.Action) {
        let blockIds = [block.id]

        self.listService.setAlign.action(contextID: self.contextId, blockIds: blockIds, alignment: alignment.asModel())
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("setAlignment: \(error.localizedDescription)")
                }
            }) { [weak self] (value) in
                let value = EventListening.PackOfEvents(contextId: value.contextID, events: value.messages, ourEvents: [])
                self?.subject?.send(.shouldHandleEvent(.init(actionType: nil, events: value)))
            }
            .store(in: &self.subscriptions)
    }

    func handleFontAction(for block: BlockActiveRecordModelProtocol, range: NSRange, fontAction: MarksPane.Panes.StylePane.FontStyle.Action) {
        guard case var .text(textContentType) = block.blockModel.information.content else { return }
        var range = range
        var blockModel = block.blockModel

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
            blockModel.information.content = .text(textContentType)
            self.documentViewInteraction?.updateBlocks(with: [blockModel.information.id])

            self.textService.setText(contextID: self.contextId,
                                            blockID: blockModel.information.id,
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
            blockModel.information.content = .text(textContentType)
            self.documentViewInteraction?.updateBlocks(with: [blockModel.information.id])
            self.textService.setText(contextID: self.contextId,
                                            blockID: blockModel.information.id,
                                            attributedString: newAttributedString)
                .sink(receiveCompletion: {_ in }, receiveValue: {})
                .store(in: &self.subscriptions)
        case .keyboard:
            typealias ColorsConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
            // TODO: Implement keyboard style https://app.clickup.com/t/fz48tc
            var keyboardColor = ColorsConverter.Colors.grey.color(background: true)
            let backgroundColor = ColorsConverter.asModel(blockModel.information.backgroundColor, background: true)
            keyboardColor = backgroundColor == keyboardColor ? ColorsConverter.Colors.default.color(background: true) : keyboardColor

            self.service.setBackgroundColor(block: block.blockModel.information, color: keyboardColor)
        }
    }
    
}
