import Foundation
import SwiftUI
import Combine
import UIKit
import os
import BlocksModels
 
class TextBlockViewModel: BaseBlockViewModel {
    private struct Options {
        var throttlingInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
    }

    private var serialQueue = DispatchQueue(label: "BlocksViews.Text.Base.SerialQueue")
    private var textOptions: Options = .init()

    // TODO: Rethink. We only need one (?) publisher to a model?
    private var toModelTextSubject: PassthroughSubject<NSAttributedString, Never> = .init()
    private var toModelAlignmentSubject: PassthroughSubject<NSTextAlignment, Never> = .init()

    weak var textView: (TextViewUpdatable & TextViewManagingFocus)?

    // For OuterWorld.
    // We should notify about user input.
    // And here we have this publisher.
    private var textViewModelSubscriptions: Set<AnyCancellable> = []
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Services
    private var service: BlockActionsServiceText = .init()

    // MARK: - Life cycle

    override init(_ block: BlockActiveRecordModelProtocol) {
        super.init(block)
        self.setupSubscribers()
    }

    // MARK: - Subclassing accessors

    override func makeContentConfiguration() -> UIContentConfiguration {
        let configuration = TextBlockContentConfiguration(textViewDelegate: self,
                                                          viewModel: self,
                                                          marksPaneActionSubject: marksPaneActionSubject,
                                                          toolbarActionSubject: toolbarActionSubject)
        return configuration
    }

    // MARK: Contextual Menu
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        guard case let .text(text) = self.getBlock().content else {
            return .init(title: "", children: [])
        }
        var actions: [BlocksViews.ContextualMenu.MenuAction] = [.create(action: .general(.addBlockBelow))]
        if text.contentType != .title {
            actions.append(contentsOf: [
                .create(action: .specific(.turnInto)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .general(.moveTo))
            ])
        }
        actions.append(.create(action: .specific(.style)))
        return .init(title: "", children: actions)
    }
    
    override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        // After we show contextual menu on UITextView (which is first responder)
        // displaying keyboard on such UITextView becomes impossible (only caret show)
        // it is possible to show it only by changing first responder with other UITextView
        let focusPosition = textView?.obtainFocusPosition()
        textView?.shouldResignFirstResponder()
        super.handle(contextualMenuAction: contextualMenuAction)

        // We want to restore focus only in case of turn into action
        if !focusPosition.isNil, case let .specific(action) = contextualMenuAction, action == .turnInto {
            let focus = TextViewFocus(position: focusPosition)
            textView?.setFocus(focus)
        }
    }
}

// MARK: - Methods called by View

extension TextBlockViewModel {

    func refreshTextViewModel() {
        let block = self.getBlock()
        let information = block.blockModel.information

        switch information.content {
        case let .text(blockType):
            let attributedText = blockType.attributedText

            let alignment = BlocksModelsParserCommonAlignmentUIKitConverter.asUIKitModel(information.alignment)
            let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(blockType.color)

            let textViewUpdate = TextViewUpdate.payload(.init(attributedString: attributedText,
                                                              auxiliary: .init(textAlignment: alignment ?? .left, blockColor: blockColor)))
            textView?.apply(update: textViewUpdate)
        default: return
        }
    }
}


// MARK: - TextViewDelegate

extension TextBlockViewModel: TextViewDelegate {
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        send(actionsPayload: .becomeFirstResponder(getBlock().blockModel))
    }

    func sizeChanged() {
        needsUpdateLayout()
    }
}

// MARK: - Setup

private extension TextBlockViewModel {

    func setupSubscribers() {
        // ToView
        let alignmentPublisher = self.getBlock().didChangeInformationPublisher()
            .map(\.alignment)
            .map(BlocksModelsParserCommonAlignmentUIKitConverter.asUIKitModel)
            .removeDuplicates()
            .safelyUnwrapOptionals()

        // We need it for Merge requests.
        // Maybe we should do it differently.
        // We change subscription on didChangePublisher to reflect changes ONLY from specific events like `Merge`.
        // If we listen `changeInformationPublisher()`, we will receive whole data from every change.
        let modelDidChangeOnMergePublisher = self.getBlock().didChangePublisher().receive(on: serialQueue)
            .map { [weak self] _ -> BlockContent.Text? in
                let value = self?.getBlock().blockModel.information
                switch value?.content {
                case let .text(value): return value
                default: return nil
                }
            }
            .safelyUnwrapOptionals()

        Publishers.CombineLatest(modelDidChangeOnMergePublisher, alignmentPublisher)
            .receiveOnMain()
            .map({ value -> TextViewUpdate in
                let (text, alignment) = value
                let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(text.color)
                return .payload(.init(attributedString: text.attributedText, auxiliary: .init(textAlignment: alignment,
                                                                                              blockColor: blockColor)))
            })
            .sink { [weak self] (value) in
                self?.textView?.apply(update: value)
            }.store(in: &self.subscriptions)

        /// FromModel
        /// ???
        /// Actually, when we open page, we get BlockShow event.
        /// This event contains actual state of all blocks.

        /// ToModel
        /// Maybe add throttle.

        self.toModelTextSubject.receive(on: serialQueue).sink { [weak self] (value) in
            self?.setModelData(attributedText: value)
        }.store(in: &self.subscriptions)

        self.toModelAlignmentSubject.debounce(for: self.textOptions.throttlingInterval, scheduler: serialQueue).notableError().flatMap({ [weak self] (value) in
            self?.apply(alignment: value) ?? .empty()
        }).sinkWithDefaultCompletion("TextBlocksViews setAlignment") { _ in }.store(in: &self.subscriptions)
    }
}

// MARK: - Set Focus

extension TextBlockViewModel {
    func set(focus: TextViewFocus?) {
        textView?.setFocus(focus)
    }
    
    func focusPosition() -> BlockFocusPosition? {
        textView?.obtainFocusPosition()
    }
}

// MARK: - Actions Payload Legacy

extension TextBlockViewModel {
    func send(textViewAction: TextBlockUserInteraction) {
        self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: textViewAction)))
    }
}

// MARK: - ViewModel / Apply to model

private extension TextBlockViewModel {
    func setModelData(attributedText: NSAttributedString) {
        // Update model.
        self.update { (block) in
            switch block.content {
            case var .text(value):
                guard value.attributedText != attributedText else { return }
                let attributedText: NSAttributedString = .init(attributedString: attributedText)
                value.attributedText = attributedText
                var blockModel = block.blockModel
                blockModel.information.content = .text(value)
            default: return
            }
        }
    }

    func apply(alignment: NSTextAlignment) -> AnyPublisher<Void, Error>? {
        let block = self.getBlock()
        guard let contextID = block.findRoot()?.blockId, case .text = block.content else { return nil }
        let blocksIds = [block.blockId]
        return self.service.setAlignment(contextID: contextID, blockIds: blocksIds, alignment: alignment)
    }

    func apply(update: TextViewUpdate) {
        switch update {
        case let .text(value): self.setModelData(attributedText: NSAttributedString(string: value))
        case let .attributedText(value): return self.setModelData(attributedText: value)
        case .auxiliary: return
        case .payload: return
        }
    }
}

// MARK: - TextViewUserInteractionProtocol

extension TextBlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: BlockTextView.UserAction) {
        switch action {
        case let .addBlockAction(value):
            switch value {
            case .addBlock:
                self.send(userAction: .toolbars(.addBlock(.init(output: self.toolbarActionSubject))))
            }
        case .showStyleMenu:
            self.send(actionsPayload: .showStyleMenu(blockModel: self.getBlock().blockModel, blockViewModel: self))
        case .showMultiActionMenuAction(.showMultiActionMenu):
            self.textView?.shouldResignFirstResponder()
            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        case .inputAction, .keyboardAction:
            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        case .changeCaretPosition:
            typealias TextBlockInteraction = BaseBlockViewModel.ActionsPayload.TextBlocksViewsUserInteraction
            self.send(actionsPayload: .textView(TextBlockInteraction(model: getBlock(), action: .textView(action))))
        }
    }
}

// MARK: - Debug

extension TextBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        guard case let .text(text) = information.content else {
            return "id: \(blockId) text block with wrong content type!!! See BlockInformation"
        }
        return "id: \(blockId)\ntext: \(text.attributedText.string.prefix(20))...\ntype: \(text.contentType)"
    }
}
