import Foundation
import SwiftUI
import Combine
import UIKit
import os
import BlocksModels
 
class TextBlockViewModel: BaseBlockViewModel {

    weak var textView: (TextViewUpdatable & TextViewManagingFocus)?

    // MARK: - Private variables
    
    private let serialQueue = DispatchQueue(label: "BlocksViews.Text.Base.SerialQueue")

    private let service: BlockActionsServiceText = .init()
    
    // TODO: Rethink. We only need one (?) publisher to a model?
    private let toModelTextSubject: PassthroughSubject<NSAttributedString, Never> = .init()
    private let toModelAlignmentSubject: PassthroughSubject<NSTextAlignment, Never> = .init()
    
    // For OuterWorld.
    // We should notify about user input.
    // And here we have this publisher.
    private var textViewModelSubscriptions: Set<AnyCancellable> = []
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializers

    override init(_ block: BlockActiveRecordModelProtocol) {
        super.init(block)
        
        setupSubscribers()
    }

    // MARK: - Subclassing accessors

    override func makeContentConfiguration() -> UIContentConfiguration {
        TextBlockContentConfiguration(
            textViewDelegate: self,
            viewModel: self,
            marksPaneActionSubject: marksPaneActionSubject,
            toolbarActionSubject: toolbarActionSubject
        )
    }

    // MARK: - Contextual Menu
    
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        guard case let .text(text) = self.getBlock().content else {
            return .init(title: "", children: [])
        }
        
        let actions: [BlocksViews.ContextualMenu.MenuAction] = {
            var result: [BlocksViews.ContextualMenu.MenuAction] = [
                .create(action: .general(.addBlockBelow))
            ]
            
            guard text.contentType != .title else { return result }
            
            result.append(
                contentsOf: [
                    .create(action: .specific(.turnIntoPage)),
                    .create(action: .general(.delete)),
                    .create(action: .general(.duplicate))
                ]
            )
            
            return result
        }()
        
        
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
        if !focusPosition.isNil,
           case let .specific(action) = contextualMenuAction,
           action == .turnIntoPage
        {
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
            
            let alignment = information.alignment.asTextAlignment
            let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(blockType.color)
            
            let textViewUpdate = TextViewUpdate.payload(
                .init(
                    attributedString: attributedText,
                    auxiliary: .init(
                        textAlignment: alignment,
                        blockColor: blockColor
                    )
                )
            )
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
            .map { $0.asTextAlignment }
            .removeDuplicates()
            .safelyUnwrapOptionals()

        // We need it for Merge requests.
        // Maybe we should do it differently.
        // We change subscription on didChangePublisher to reflect changes ONLY from specific events like `Merge`.
        // If we listen `changeInformationPublisher()`, we will receive whole data from every change.
        let modelDidChangeOnMergePublisher = self.getBlock().didChangePublisher()
            .receive(on: serialQueue)
            .map { [weak self] _ -> BlockContent.Text? in
                guard let value = self?.getBlock().blockModel.information else { return nil }
                
                switch value.content {
                case let .text(value):
                    return value
                default:
                    return nil
                }
            }
            .safelyUnwrapOptionals()

        Publishers.CombineLatest(modelDidChangeOnMergePublisher, alignmentPublisher)
            .receiveOnMain()
            .map { value -> TextViewUpdate in
                let (text, alignment) = value
                let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(text.color)
                return .payload(
                    .init(
                        attributedString: text.attributedText,
                        auxiliary: .init(
                            textAlignment: alignment,
                            blockColor: blockColor
                        )
                    )
                )
            }
            .sink { [weak self] value in
                self?.textView?.apply(update: value)
            }
            .store(in: &self.subscriptions)

        /// FromModel
        /// ???
        /// Actually, when we open page, we get BlockShow event.
        /// This event contains actual state of all blocks.

        /// ToModel
        /// Maybe add throttle.

        self.toModelTextSubject
            .receive(on: serialQueue)
            .sink { [weak self] value in
                self?.setModelData(attributedText: value)
            }
            .store(in: &self.subscriptions)

        self.toModelAlignmentSubject.debounce(
            for: Constants.throttlingInterval,
            scheduler: serialQueue
        )
        .notableError()
        .flatMap { [weak self] value in
            self?.apply(alignment: value) ?? .empty()
        }
        .sinkWithDefaultCompletion("TextBlocksViews setAlignment") { _ in }
        .store(in: &self.subscriptions)
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
        self.send(
            actionsPayload: .textView(
                .init(
                    model: self.getBlock(),
                    action: textViewAction
                )
            )
        )
    }
    
}

// MARK: - ViewModel / Apply to model

private extension TextBlockViewModel {
    
    func setModelData(attributedText: NSAttributedString) {
        // Update model.
        self.update { block in
            switch block.content {
            case var .text(value):
                guard value.attributedText != attributedText else { return }
                
                value.attributedText = NSAttributedString(attributedString: attributedText)
                
                var blockModel = block.blockModel
                blockModel.information.content = .text(value)
                
            default:
                return
            }
        }
    }

    func apply(alignment: NSTextAlignment) -> AnyPublisher<Void, Error>? {
        let block = self.getBlock()
        
        guard
            let contextID = block.findRoot()?.blockId,
            case .text = block.content
        else { return nil }
        
        return self.service.setAlignment(
            contextID: contextID,
            blockIds: [block.blockId],
            alignment: alignment
        )
    }

    func apply(update: TextViewUpdate) {
        switch update {
        case let .text(value):
            setModelData(attributedText: NSAttributedString(string: value))
        case let .attributedText(value):
            setModelData(attributedText: value)
        case .auxiliary:
            return
        case .payload:
            return
        }
    }
    
}

// MARK: - TextViewUserInteractionProtocol

extension TextBlockViewModel: TextViewUserInteractionProtocol {
    
    func didReceiveAction(_ action: BlockTextView.UserAction) {
        switch action {
        case .addBlockAction:
            self.send(
                userAction: .toolbars(
                    .addBlock(.init(output: self.toolbarActionSubject))
                )
            )
        case .showStyleMenu:
            self.send(
                actionsPayload: .showStyleMenu(
                    blockModel: self.getBlock().blockModel,
                    blockViewModel: self
                )
            )
        case .showMultiActionMenuAction:
            self.textView?.shouldResignFirstResponder()
            self.send(
                actionsPayload: .textView(
                    .init(
                        model: self.getBlock(),
                        action: .textView(action)
                    )
                )
            )
        case .inputAction, .keyboardAction:
            self.send(
                actionsPayload: .textView(
                    .init(
                        model: self.getBlock(),
                        action: .textView(action))
                )
            )
        case .changeCaretPosition:
            self.send(
                actionsPayload: .textView(
                    BaseBlockViewModel.ActionsPayload.TextBlocksViewsUserInteraction(
                        model: getBlock(),
                        action: .textView(action)
                    )
                )
            )
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

// MARK: - Constants

private extension TextBlockViewModel {
    
    enum Constants {
        static let throttlingInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
    }
    
}
