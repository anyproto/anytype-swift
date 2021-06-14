import Foundation
import SwiftUI
import Combine
import UIKit
import os
import BlocksModels
 
class TextBlockViewModel: BaseBlockViewModel {
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

    // MARK: View state
    private(set) var shouldResignFirstResponder = PassthroughSubject<Void, Never>()
    @Published private(set) var textViewUpdate: TextViewUpdate?
    private(set) var setFocus = PassthroughSubject<BlockFocusPosition, Never>()
    
    private weak var blockActionHandler: NewBlockActionHandler?

    // MARK: - Life cycle

    override init(_ block: BlockActiveRecordModelProtocol) {
        assertionFailure("Do not use this init")
        
        super.init(block)
        setupSubscribers()
    }
    
    init(_ block: BlockActiveRecordModelProtocol, blockActionHandler: NewBlockActionHandler?) {
        self.blockActionHandler = blockActionHandler
        super.init(block)
        setupSubscribers()
    }

    // MARK: - Subclassing accessors

    override func makeContentConfiguration() -> UIContentConfiguration {
        TextBlockContentConfiguration(
            textViewDelegate: self,
            viewModel: self,
            toolbarActionSubject: toolbarActionSubject,
            blockActionHandler: blockActionHandler
        )
    }

    // MARK: - Contextual Menu
    
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        guard case let .text(text) = block.content else {
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
                    .create(action: .general(.duplicate)),
                    .create(action: .specific(.style))
                ]
            )
            
            return result
        }()
        
        
        return .init(title: "", children: actions)
    }

    override func updateView() {
        refreshedTextViewUpdate()
    }
    
}

// MARK: - Methods called by View

extension TextBlockViewModel {

    func refreshedTextViewUpdate() {
        let block = self.block
        let information = block.blockModel.information

        switch information.content {
        case let .text(blockType):
            let attributedText = blockType.attributedText
            
            let alignment = information.alignment.asTextAlignment
            let blockColor = MiddlewareColorConverter.asModel(blockType.color)

            textViewUpdate = TextViewUpdate.payload(
                .init(
                    attributedString: attributedText,
                    auxiliary: .init(
                        textAlignment: alignment,
                        blockColor: blockColor
                    )
                )
            )
        default: return
        }
    }
}


// MARK: - TextViewDelegate

extension TextBlockViewModel: TextViewDelegate {
    
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        send(actionsPayload: .becomeFirstResponder(block.blockModel))
    }

    func sizeChanged() {
        needsUpdateLayout()
    }
    
}

// MARK: - Setup

private extension TextBlockViewModel {

    func setupSubscribers() {
        // ToView
        let alignmentPublisher = block.didChangeInformationPublisher()
            .map(\.alignment)
            .map { $0.asTextAlignment }
            .removeDuplicates()
            .safelyUnwrapOptionals()

        // We need it for Merge requests.
        // Maybe we should do it differently.
        // We change subscription on didChangePublisher to reflect changes ONLY from specific events like `Merge`.
        // If we listen `changeInformationPublisher()`, we will receive whole data from every change.
        let modelDidChangeOnMergePublisher = block.didChangePublisher()
            .receive(on: serialQueue)
            .map { [weak self] _ -> BlockText? in
                guard let value = self?.block.blockModel.information else { return nil }
                
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
                let blockColor = MiddlewareColorConverter.asModel(text.color)
                return .payload(.init(attributedString: text.attributedText, auxiliary: .init(textAlignment: alignment,
                                                                                              blockColor: blockColor)))
            }
            .sink { [weak self] (textViewUpdate) in
                guard let self = self else { return }
                self.textViewUpdate = textViewUpdate
            }.store(in: &self.subscriptions)

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
    func set(focus: BlockFocusPosition) {
        self.setFocus.send(focus)
    }
}

// MARK: - Actions Payload Legacy

extension TextBlockViewModel {
    
    func send(textViewAction: TextBlockUserInteraction) {
        self.send(
            actionsPayload: .textView(
                .init(
                    model: block,
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
        let block = self.block
        
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
                    userAction: .addBlock(.init(output: self.toolbarActionSubject))
                )
            case .showStyleMenu:
                self.send(
                    actionsPayload: .showStyleMenu(
                        blockModel: block.blockModel,
                        blockViewModel: self
                    )
                )
            case .showMultiActionMenuAction:
                self.shouldResignFirstResponder.send()
                self.send(
                    actionsPayload: .textView(
                        .init(
                            model: block,
                            action: .textView(action)
                        )
                    )
                )
            case .inputAction, .keyboardAction:
                self.send(
                    actionsPayload: .textView(
                        .init(
                            model: block,
                            action: .textView(action))
                    )
                )
            case .changeCaretPosition:
                self.send(
                    actionsPayload: .textView(
                        ActionsPayload.TextBlocksViewsUserInteraction(
                            model: block,
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
        let address = String(format: "%p", unsafeBitCast(self, to: Int.self))

        return "\(address)\nid: \(blockId)\ntext: \(text.attributedText.string.prefix(20))...\ntype: \(text.contentType)\n"
    }
    
}

// MARK: - Constants

private extension TextBlockViewModel {
    
    enum Constants {
        static let throttlingInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
    }
    
}
