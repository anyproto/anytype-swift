//
//  BlocksViews+New+Text+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.Text.Base

private extension Logging.Categories {
    static let textBlocksViewsBase: Self = "BlocksViews.New.Text.Base"
}

extension BlocksViews.New.Text {
    enum Base {}
}

// MARK: - Options
extension Namespace {
    struct Options {
        var throttlingInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
        var shouldApplyChangesLocally: Bool = false
        var shouldStopSetupTextViewModel: Bool = false
    }
}

private extension Namespace {
    class TextViewModelHolder {
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
}

// MARK: - Base / ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.Base.ViewModel {
        typealias BlocksModelsUpdater = TopLevel.AliasesMap.BlockTools.Updater
        typealias BlockModelId = TopLevel.AliasesMap.BlockId
        typealias FocusPosition = TopLevel.AliasesMap.FocusPosition

        private var serialQueue = DispatchQueue(label: "BlocksViews.New.Text.Base.SerialQueue")
        
        @Environment(\.developerOptions) var developerOptions
        private var textOptions: Namespace.Options = .init()
        
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
        private var toModelSizeDidChangeSubject: PassthroughSubject<CGSize, Never> = .init()
        
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
                let logger = Logging.createLogger(category: .todo(.refactor(String(reflecting: Self.self))))
                os_log(.debug, log: logger, "Initialization process has been cut down. You have to call 'self.setup' method.")
                return;
            }
            self.setup()
        }
        
        // MARK: - Subclassing accessors

        func getUIKitViewModel() -> TextView.UIKitTextView.ViewModel { self.textViewModel }
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration: UIContentConfiguration?
            if case let .text(text) = self.getBlock().blockModel.information.content,
               text.contentType == .toggle {
                configuration = makeToggleBlockConfiguration()
            } else {
                configuration = makeTextBlockConfiguration()
            }
            return configuration ?? super.makeContentConfiguration()
        }
        
        private func makeToggleBlockConfiguration() -> UIContentConfiguration? {
            var configuration = ToggleBlockContentConfiguration(self)
            configuration?.contextMenuHolder = self
            return configuration
        }
        
        private func makeTextBlockConfiguration() -> UIContentConfiguration? {
            let checkedAction: (Bool) -> Void = { [weak self] value in
                self?.send(textViewAction: .buttonView(.checkbox(value)))
            }
            var configuration = TextBlockContentConfiguration(self.getBlock(),
                                                                    checkedAction: checkedAction)
            configuration?.contextMenuHolder = self
            return configuration
        }

        override func makeUIView() -> UIView {
            let toViewSetBackgroundColorPublisher = self.getBlock().didChangeInformationPublisher()
                .map(\.backgroundColor)
                .removeDuplicates()
                .map {value in
                    BlocksModelsModule.Parser.Text.Color.Converter.asModel(value, background: true)
                }
                .map {
                    TopWithChildUIKitView.Resource.init(backgroundColor: $0)
                }
                .eraseToAnyPublisher()

            return TopWithChildUIKitView().configured(textView: self.getUIKitViewModel().createView()).configured(leftChild: .empty()).configured(toViewSetBackgroundColorPublisher)
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
}

// MARK: - TextViewModel
extension Namespace.ViewModel {
    private func cleanup() {
        self.subscriptions = []
    }
    private func cleanupTextViewModel() {
        self.textViewModelHolder.cleanup()
        self.textViewModelSubscriptions = []
    }
    func refreshTextViewModel(_ textViewModel: TextView.UIKitTextView.ViewModel) {
        let block = self.getBlock()
        let information = block.blockModel.information

        switch information.content {
        case let .text(blockType):
            let attributedText = blockType.attributedText

            let alignment = BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asUIKitModel(information.alignment)
            let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(blockType.color)

            textViewModel.update = .payload(.init(attributedString: attributedText,
                                                  auxiliary: .init(textAlignment: alignment ?? .left, blockColor: blockColor)))
        default: return
        }
    }
}

// MARK: - Setup
private extension Namespace.ViewModel {
    private func setupTextViewModel() {
        _ = self.textViewModel.configured(self)
    }
    
    private func setupTextViewModelSubscribers() {
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
            self?.toModelSizeDidChangeSubject.send(value)
        }.store(in: &self.textViewModelSubscriptions)
    }
    
    private func setupSubscribers() {
        // ToView
        let alignmentPublisher = self.getBlock().didChangeInformationPublisher()
            .map(\.alignment)
            .map(BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asUIKitModel)
            .removeDuplicates()
            .safelyUnwrapOptionals()

        // We need it for Merge requests.
        // Maybe we should do it differently.
        // We change subscription on didChangePublisher to reflect changes ONLY from specific events like `Merge`.
        // If we listen `didChangeInformationPublisher()`, we will receive whole data from every change.
        let modelDidChangeOnMergePublisher = self.getBlock().didChangePublisher().receive(on: serialQueue)
            .map { [weak self] _ -> TopLevel.AliasesMap.BlockContent.Text? in
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
                let logger = Logging.createLogger(category: .textBlocksViewsBase)
                os_log(.debug, log: logger, "TextBlocksViews setAlignment error has occured. %@", String(describing: error))
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
        
        self.toModelSizeDidChangeSubject.eraseToAnyPublisher().sink { [weak self] (value) in
            self?.send(sizeDidChange: value)
        }.store(in: &self.subscriptions)
    }
    
    // MARK: - Setup
    private func setup() {
        self.setupTextViewModel()
        self.setupTextViewModelSubscribers()
        self.setupSubscribers()
    }
}

// MARK: - Set Focus
extension Namespace.ViewModel {
    func set(focus: TextView.UIKitTextView.ViewModel.Focus?) {
        self.textViewModel.set(focus: focus)
    }
}

// MARK: - Actions Payload Legacy

extension Namespace.ViewModel {
    func send(textViewAction: BlocksViews.New.Text.UserInteraction) {
        self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: textViewAction)))
    }
}

// MARK: - ViewModel / Apply to model

private extension Namespace.ViewModel {
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
        return self.service.setAlignment.action(contextID: contextID, blockIds: blocksIds, alignment: alignment)
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
extension Namespace.ViewModel: TextViewUserInteractionProtocol {
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
extension Namespace.ViewModel {
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

// MARK: - UIKitView / TopView
extension Namespace {
    class TopUIKitView: UIView {
        // TODO: Refactor
        // OR
        // We could do it on toggle level or on block parsing level?
        struct Layout {
            var containedViewInset = 8
            var indentationWidth = 8
            var boundaryWidth = 2
        }

        var layout: Layout = .init()

        // MARK: Views
        // |    contentView    | : | leftView | textView |

        var contentView: UIView!
        var leftView: UIView!
        var textView: UIView!

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }

        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }

        // MARK: UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false

            self.leftView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.textView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(leftView)
            self.contentView.addSubview(textView)

            self.addSubview(contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.leftView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.textView, let superview = view.superview, let leftView = self.leftView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }

        // MARK: Update / (Could be placed in `layoutSubviews()`)
        func updateView() {
            // toggle animation also
        }

        func updateIfNeeded(leftViewSubview: UIView?, _ setConstraints: Bool = true) {
            guard let leftViewSubview = leftViewSubview else { return }
            for view in self.leftView.subviews {
                view.removeFromSuperview()
            }
            self.leftView.addSubview(leftViewSubview)
            let view = leftViewSubview
            if setConstraints, let superview = view.superview {
                view.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }

        func updateIfNeeded(rightView: UIView?) {
            guard let textView = rightView else { return }
            for view in self.textView.subviews {
                view.removeFromSuperview()
            }
            self.textView.addSubview(textView)
            let view = textView
            if let superview = view.superview {
                view.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        // MARK: Configured
        func configured(textView: TextView.UIKitTextView?) -> Self {
            self.updateIfNeeded(rightView: textView)
            return self
        }
        
        func configured(rightView: UIView?) -> Self {
            self.updateIfNeeded(rightView: rightView)
            return self
        }
    }
}

// MARK: - UIKitView / TopWithChild
extension Namespace {
    class TopWithChildUIKitView: UIView {
        struct Resource {
            var textColor: UIColor?
            var backgroundColor: UIColor?
        }
        
        private var resourceSubscription: AnyCancellable?
        
        // TODO: Refactor
        // OR
        // We could do it on toggle level or on block parsing level?
        struct Layout {
            var containedViewInset = 8
            var indentationWidth = 8
            var boundaryWidth = 2
        }

        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |

        var contentView: UIView!
        var topView: TopUIKitView!
        var leftView: UIView!
        var onLeftChildWillLayout: (UIView?) -> () = { view in
            if let view = view, let superview = view.superview {
                var constraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor),
                ]
                if view.intrinsicContentSize.width != UIView.noIntrinsicMetric {
                    constraints.append(view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width))
                }
                if view.intrinsicContentSize.height != UIView.noIntrinsicMetric {
                    constraints.append(view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height))
                }
                NSLayoutConstraint.activate(constraints)
            }
        }

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }

        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }

        // MARK: UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false

            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.topView = {
                let view = TopUIKitView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.leftView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(topView)

            self.addSubview(contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.topView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }

        // MARK: Update / (Could be placed in `layoutSubviews()`)
        func updateView() {
            // toggle animation also
        }

        func updateIfNeeded(leftChild: UIView?, setConstraints: Bool = false) {
            guard let leftChild = leftChild else { return }
            self.topView.updateIfNeeded(leftViewSubview: leftChild, setConstraints)
            leftChild.translatesAutoresizingMaskIntoConstraints = false
            self.leftView = leftChild
            self.onLeftChildWillLayout(leftChild)
        }

        // MARK: Configured
        func configured(leftChild: UIView?, setConstraints: Bool = false) -> Self {
            self.updateIfNeeded(leftChild: leftChild, setConstraints: setConstraints)
            return self
        }

        func configured(textView: TextView.UIKitTextView?) -> Self {
            _ = self.topView.configured(textView: textView)
            return self
        }
        
        func configured(rightView: UIView?) -> Self {
            _ = self.topView.configured(rightView: rightView)
            return self
        }
        
        fileprivate func configured(_ resourceStream: AnyPublisher<Resource, Never>) -> Self {
            self.resourceSubscription = resourceStream.receive(on: DispatchQueue.main).sink { [weak self] (value) in            
                self?.backgroundColor = value.backgroundColor
            }
            return self
        }
    }
}
