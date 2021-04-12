import Foundation
import SwiftUI
import Combine
import UIKit
import os
import BlocksModels


private final class TextViewModelHolder {
    private var viewModel: TextView.UIKitTextView.ViewModel?

    init(_ viewModel: TextView.UIKitTextView.ViewModel?) {
        self.viewModel = viewModel
    }

    func cleanup() {
        self.viewModel = nil
    }

    func apply(_ update: TextView.UIKitTextView.ViewModel.Update) {
        if let viewModel = self.viewModel {
            viewModel.update = update
        }
    }
}

// MARK: - Base / ViewModel

final class TextBlockViewModel: BlocksViews.Base.ViewModel {
    typealias BlocksModelsUpdater = TopLevel.BlockTools.Updater
    typealias BlockModelId = BlockId
    typealias FocusPosition = TopLevel.FocusPosition

    private struct Options {
        var throttlingInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
        var shouldApplyChangesLocally: Bool = false
        var shouldStopSetupTextViewModel: Bool = false
    }

    private var serialQueue = DispatchQueue(label: "BlocksViews.Text.Base.SerialQueue")
    private var textOptions: Options = .init()

    /// TODO: Begin to use publishers and values in this view.
    /// We could directly set a state or a parts of this viewModel state.
    /// This should fire updates and corresponding view will be updated.
    ///
    private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
    private lazy var textViewModelHolder: TextViewModelHolder = {
        .init(self.textViewModel)
    }()

    // TODO: Rethink. We only need one (?) publisher to a model?
    private var toModelTextSubject: PassthroughSubject<NSAttributedString, Never> = .init()
    private var toModelAlignmentSubject: PassthroughSubject<NSTextAlignment, Never> = .init()

    // For OuterWorld.
    // We should notify about user input.
    // And here we have this publisher.
    private var textViewModelSubscriptions: Set<AnyCancellable> = []
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Services
    private var service: BlockActionsServiceText = .init()

    // MARK: - Life cycle

    override init(_ block: BlockModel) {
        super.init(block)
        if self.textOptions.shouldStopSetupTextViewModel {
            assertionFailure("Initialization process has been cut down. You have to call 'self.setup' method.")
            return
        }
        self.setup()
    }

    // MARK: - Subclassing accessors

    func getUIKitViewModel() -> TextView.UIKitTextView.ViewModel { self.textViewModel }

    override func makeContentConfiguration() -> UIContentConfiguration {
        guard case let .text(text) = self.getBlock().blockModel.information.content else {
            return super.makeContentConfiguration()
        }
        switch text.contentType {
        case .toggle:
            return ToggleBlockContentConfiguration(self)
        case .code:
            return makeCodeBlockConfiguration()
        default:
            return makeTextBlockConfiguration()
        }
    }

    // TODO: we shouldn't did it here
    private func makeCodeBlockConfiguration() -> UIContentConfiguration {
        var configuration = CodeBlockContentConfiguration(self)
        configuration.contextMenuHolder = self
        return configuration
    }
    
    private func makeTextBlockConfiguration() -> UIContentConfiguration {
        let checkedAction: (Bool) -> Void = { [weak self] value in
            self?.send(textViewAction: .buttonView(.checkbox(value)))
        }
        var configuration = TextBlockContentConfiguration(self.getBlock(),
                                                          checkedAction: checkedAction)
        configuration.contextMenuHolder = self
        return configuration
    }

    override func makeUIView() -> UIView {
        let toViewSetBackgroundColorPublisher = self.getBlock().didChangeInformationPublisher()
            .map(\.backgroundColor)
            .removeDuplicates()
            .map {value in
                MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(value, background: true)
            }
            .map {
                TopWithChildUIKitView.Resource.init(backgroundColor: $0)
            }
            .eraseToAnyPublisher()

        return TopWithChildUIKitView()
            .configured(textView: self.getUIKitViewModel().createView())
            .configured(leftChild: .empty())
            .configured(toViewSetBackgroundColorPublisher)
    }

    // MARK: Contextual Menu
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .specific(.turnInto)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate)),
            .create(action: .general(.moveTo)),
            .create(action: .specific(.style)),
        ])
    }
}

// MARK: - Methods called by View

extension TextBlockViewModel {

    func refreshTextViewModel(_ textViewModel: TextView.UIKitTextView.ViewModel) {
        let block = self.getBlock()
        let information = block.blockModel.information

        switch information.content {
        case let .text(blockType):
            let attributedText = blockType.attributedText

            let alignment = BlocksModelsParserCommonAlignmentUIKitConverter.asUIKitModel(information.alignment)
            let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(blockType.color)

            textViewModel.update = .payload(.init(attributedString: attributedText,
                                                  auxiliary: .init(textAlignment: alignment ?? .left, blockColor: blockColor)))
        default: return
        }
    }

    /// Show view with code language selection
    /// - Parameter completion: Return in completion selected code language as `String` type
    func needsShowCodeLanguageView(with languages: [String], completion: @escaping (_ language: String) -> Void) {
        self.send(actionsPayload: .showCodeLanguageView(languages: languages, completion: completion))
    }
}

// MARK: - Setup

private extension TextBlockViewModel {
    func setupTextViewModel() {
        _ = self.textViewModel.configured(self)
    }

    func setupTextViewModelSubscribers() {
        /// FromView
        self.getUIKitViewModel().richUpdatePublisher.sink { [weak self] (value) in
            switch value {
            case let .attributedText(text): self?.toModelTextSubject.send(text)
            default: return
            }
        }.store(in: &self.textViewModelSubscriptions)

        self.getUIKitViewModel().auxiliaryPublisher.sink { [weak self] (value) in
            switch value {
            case let .auxiliary(value): self?.toModelAlignmentSubject.send(value.textAlignment)
            default: return
            }
        }.store(in: &self.textViewModelSubscriptions)

        self.getUIKitViewModel().sizePublisher.sink { [weak self] (value) in
            self?.needsUpdateLayout()
        }.store(in: &self.textViewModelSubscriptions)
    }

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
        // If we listen `didChangeInformationPublisher()`, we will receive whole data from every change.
        let modelDidChangeOnMergePublisher = self.getBlock().didChangePublisher().receive(on: serialQueue)
            .map { [weak self] _ -> TopLevel.BlockContent.Text? in
                let value = self?.getBlock().blockModel.information
                switch value?.content {
                case let .text(value): return value
                default: return nil
                }
            }
            .safelyUnwrapOptionals()

        Publishers.CombineLatest(modelDidChangeOnMergePublisher, alignmentPublisher)
            .receive(on: DispatchQueue.main)
            .map({ value -> TextView.UIKitTextView.ViewModel.Update in
                let (text, alignment) = value
                let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(text.color)
                return .payload(.init(attributedString: text.attributedText, auxiliary: .init(textAlignment: alignment,
                                                                                              blockColor: blockColor)))
            })
            .sink { [weak self] (value) in
                self?.textViewModelHolder.apply(value)
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
        }).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("TextBlocksViews setAlignment error has occured. \(error)")
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
    }

    // MARK: - Setup
    func setup() {
        self.setupTextViewModel()
        self.setupTextViewModelSubscribers()
        self.setupSubscribers()
    }
}

// MARK: - Set Focus

extension TextBlockViewModel {
    func set(focus: TextView.UIKitTextView.ViewModel.Focus?) {
        self.textViewModel.set(focus: focus)
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
            switch block.blockModel.information.content {
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
        guard let contextID = block.findRoot()?.blockModel.information.id, case .text = block.blockModel.information.content else { return nil }
        let blocksIds = [block.blockModel.information.id]
        return self.service.setAlignment(contextID: contextID, blockIds: blocksIds, alignment: alignment)
    }

    func apply(update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value): self.setModelData(attributedText: NSAttributedString(string: value))
        case let .attributedText(value): return self.setModelData(attributedText: value)
        case .auxiliary: return
        case .payload: return
        }
    }
}

// MARK: - TextViewUserInteractionProtocol

extension TextBlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        switch action {
        case let .addBlockAction(value):
            switch value {
            case .addBlock: self.send(userAction: .toolbars(.addBlock(.init(output: self.toolbarActionSubject))))
            }

        case .showMultiActionMenuAction(.showMultiActionMenu):
            self.getUIKitViewModel().shouldResignFirstResponder()
            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))

        default: self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        }
    }
}

// MARK: - Debug

extension TextBlockViewModel {
    // Class scope, actually.
    class func debugString(_ unique: Bool, _ id: BlockModelId) -> String {
        unique ? self.defaultDebugStringUnique(id) : self.defaultDebugString()
    }
    class func defaultDebugStringUnique(_ id: BlockModelId) -> String {
        self.defaultDebugString() + id.description.prefix(10)
    }
    class func defaultDebugString() -> String {
        .init("\(String(reflecting: self))".split(separator: ".").dropLast().last ?? "")
    }
}
