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
    }
}

// MARK: - Base / ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.Base.ViewModel {
        typealias BlocksModelsUpdater = TopLevel.AliasesMap.BlockTools.Updater
        typealias BlockModelId = TopLevel.AliasesMap.BlockId
        typealias FocusPosition = TopLevel.AliasesMap.FocusPosition
        
        @Environment(\.developerOptions) var developerOptions
        private var textOptions: Namespace.Options = .init()
        
        private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
        
        // MARK: - Publishers
        /// As always, lets keep an eye on these properties a little bit.
        /// `toViewText` `@Published` variable keep state of new coming value from a model.
        /// However, we should skip additional cycle for `toModelText`
        /// That means, that we need `toModelTextSubject`.
        /// We shouldn't take care about a value, because user initiates events.
        /// So, we need only to listen his typing.
        ///
        @Published private var toViewText: NSAttributedString? { willSet { self.objectWillChange.send() } }
        @Published private var toViewTextAlignment: NSTextAlignment? { willSet { self.objectWillChange.send() } }
        @Published private var toViewSetFocusPosition: FocusPosition?
        @Published private var toViewSetBackgroundColor: UIColor?
        
        private var toViewUpdates: AnyPublisher<TextView.UIKitTextView.ViewModel.Update, Never> = .empty()
        
        private var toModelTextSubject: PassthroughSubject<NSAttributedString, Never> = .init()
        private var toModelAlignmentSubject: PassthroughSubject<NSTextAlignment, Never> = .init()
        
        /// For OuterWorld.
        /// We should notify about user input.
        /// And here we have this publisher.
        ///
        var textDidChangePublisher: AnyPublisher<NSAttributedString, Never> = .empty()
        
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: - Services
        private var service: ServiceLayerModule.Text.BlockActionsService = .init()
        
        // MARK: - Convenient accessors.
        var text: String {
            set {
                if self.toViewText != nil {
                    self.toViewText = .init(string: newValue)
                }
            }
            get {
                self.toViewText?.string ?? ""
            }
        }
                
        // MARK: Subclassing
        override init(_ block: BlockModel) {
            super.init(block)
            self.setup()
        }
        
        // MARK: Subclassing accessors
        func getUIKitViewModel() -> TextView.UIKitTextView.ViewModel { self.textViewModel }
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
        }

        override func makeUIView() -> UIView {
            TopWithChildUIKitView().configured(textView: self.getUIKitViewModel().createView()).configured(leftChild: .empty()).configured(self.$toViewSetBackgroundColor.map({TopWithChildUIKitView.Resource.init(backgroundColor: $0)}).eraseToAnyPublisher())
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
                .create(action: .specific(.color)),
                .create(action: .specific(.backgroundColor)),
            ])
        }
    }
}

// MARK: - Setup
private extension Namespace.ViewModel {
    private func setupTextViewModel() {
        _ = self.textViewModel.configured(self)
    }
    
    private func setupSubscribers() {
        
        /// FromView
        self.textViewModel.richUpdatePublisher.sink { [weak self] (value) in
            switch value {
            case let .attributedText(text): self?.toModelTextSubject.send(text)
            default: return
            }
        }.store(in: &self.subscriptions)
        
        self.textViewModel.auxiliaryPublisher.sink { [weak self] (value) in
            switch value {
            case let .auxiliary(value): self?.toModelAlignmentSubject.send(value.textAlignment)
            default: return
            }
        }.store(in: &self.subscriptions)
        
        /// ToView
        let alignmentPublisher = self.getBlock().didChangeInformationPublisher().map(\.alignment).map(BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asUIKitModel).removeDuplicates().safelyUnwrapOptionals()
        self.toViewUpdates = Publishers.CombineLatest(self.$toViewText.safelyUnwrapOptionals(), alignmentPublisher).receive(on: RunLoop.main).map({ value -> TextView.UIKitTextView.ViewModel.Update in
            let (text, alignment) = value
            return .payload(.init(attributedString: text, auxiliary: .init(textAlignment: alignment)))
        }).eraseToAnyPublisher()
        
        /// We should subscribe on view updates.
        /// For now, we have two different publishers.
        /// It is fine, but, what is under the hood?
        /// We should initiate update of view by ourselves on `setFocus` or on `Merge`.
        /// It is a job for `ephemeral passthroughSubject` and `intentional update of text view model`.
        /// But
        /// For `initial` state we should update some stored property.
        /// And it is `@Published update` property of TextView.ViewModel.
        self.toViewUpdates.sink { [weak self] (value) in
            self?.textViewModel.intentional(update: value)
        }.store(in: &self.subscriptions)
        
        self.toViewUpdates.sink { [weak self] (value) in
            self?.textViewModel.update = value
        }.store(in: &self.subscriptions)
        
        self.$toViewSetFocusPosition.sink { [weak self] (value) in
            self?.textViewModel.setFocus = .init(position: value, completion: { [weak self] (value) in
                /// HACK:
                /// Look at `diffable` documentation for details.
                /// Now it consists of two entries.
                /// `diffable` = `contentType` + `blockId`.
                /// If we change content type, we change a class of view model.
                /// This update is not destructive ( like add or delete ) and associated `textView` still exists.
                /// This `textView` will catch event.
                /// We would like to prevent it.
                /// We would like to deliver event to a view which could handle it.
                ///
                /// --
                /// This hack can be removed, when we extract a widget `textView` and we will transfer it between viewModels.
                /// --
                ///
                if self?.makeDiffable() != self?.diffable {
                    let logger = Logging.createLogger(category: .textBlocksViewsBase)
                    os_log(.debug, log: logger, "TextBlocksViews toViewSetFocusPosition. Skip set focus for block: %@", String(describing: self?.getBlock().blockModel.information.id))
                    return
                }
                var model = self?.getBlock()
                model?.unsetFocusAt()
                model?.unsetFirstResponder()
                
                /// Break possible cyclic setFocus.
                self?.toViewSetFocusPosition = nil
            })
        }.store(in: &self.subscriptions)
        
        // From Model
        self.getBlock().container?.userSession.didChangePublisher().sink(receiveValue: { [weak self] (value) in
            if let block = self?.getBlock(), block.isFirstResponder {
                self?.toViewSetFocusPosition = block.focusAt
            }
        }).store(in: &self.subscriptions)
        
        self.getBlock().didChangeInformationPublisher().map({ value -> TopLevel.AliasesMap.BlockContent.Text? in
            switch value.content {
            case let .text(value): return value
            default: return nil
            }
        }).removeDuplicates().safelyUnwrapOptionals().sink { [weak self] (value) in
            /// Update data(?)
            self?.toViewText = value.attributedText
        }.store(in: &self.subscriptions)
        
        self.getBlock().didChangeInformationPublisher().map({ value in value.backgroundColor }).removeDuplicates().sink { [weak self] (value) in
            let result = BlocksModelsModule.Parser.Text.Color.Converter.asModel(value, background: true)
            self?.toViewSetBackgroundColor = result
        }.store(in: &self.subscriptions)
        
        //                self.blockUpdatesPublisher.map(\.information.alignment).map(Alignment.Converter.asModel(_:)).sink { [weak self] (value) in
        //
        //                }.store(in: &self.subscriptions)
        
        /// FromModel
        /// ???
        /// Actually, when we open page, we get BlockShow event.
        /// This event contains actual state of all blocks.
        
        /// ToModel
        /// Maybe add throttle.
//        .throttle(for: 30, scheduler: DispatchQueue.global(), latest: true)
        
        self.toModelTextSubject.debounce(for: self.textOptions.throttlingInterval, scheduler: DispatchQueue.global()).notableError().flatMap({ [weak self] (value) in
            self?.apply(attributedText: value) ?? .empty()
        }).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textBlocksViewsBase)
                os_log(.debug, log: logger, "TextBlocksViews setBlockText error has occured. %@", String(describing: error))
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
        
//        .throttle(for: 30, scheduler: DispatchQueue.global(), latest: true)
        self.toModelAlignmentSubject.debounce(for: self.textOptions.throttlingInterval, scheduler: DispatchQueue.main).notableError().receive(on: DispatchQueue.global()).flatMap({ [weak self] (value) in
            self?.apply(alignment: value) ?? .empty()
        }).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textBlocksViewsBase)
                os_log(.debug, log: logger, "TextBlocksViews setAlignment error has occured. %@", String(describing: error))
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
        
        /// TextDidChange For OuterWorld
        let textDidChangePublisher = self.textViewModel.richUpdatePublisher.map{ value -> NSAttributedString? in
            switch value {
            case let .attributedText(text): return text
            default: return nil
            }
        }.safelyUnwrapOptionals().eraseToAnyPublisher()
        let textSizeDidChangePublisher = self.textViewModel.sizePublisher.eraseToAnyPublisher()
        self.textDidChangePublisher = Publishers.CombineLatest(textDidChangePublisher, textSizeDidChangePublisher).removeDuplicates { (lhs, rhs) -> Bool in
            lhs.1.height == rhs.1.height
        }.map(\.0).eraseToAnyPublisher()
    }
    
    // MARK: - Setup
    private func setup() {
        if self.developerOptions.current.debug.enabled {
            self.text = Self.debugString(self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldHaveUniqueText, self.blockId)
            switch self.getBlock().blockModel.information.content {
            case let .text(blockType):
                self.text = self.text + " >> " + blockType.attributedText.string
            default: return
            }
        }
        else {
            let block = self.getBlock()
            switch self.getBlock().blockModel.information.content {
            case let .text(blockType):
                self.toViewText = blockType.attributedText
//                self.toViewTextAlignment = BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asUIKitModel(block.blockModel.information.alignment)
            default: return
            }
            if block.isFirstResponder {
                self.toViewSetFocusPosition = block.focusAt
            }
        }
        self.setupTextViewModel()
        self.setupSubscribers()
    }
}

// MARK: - Actions Payload Legacy
extension Namespace.ViewModel {
    func send(textViewAction: BlocksViews.New.Text.UserInteraction) {
        self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: textViewAction)))
    }
}

// MARK: - Events
private extension Namespace.ViewModel {
    class EventListener: EventHandler {
        typealias Event = Anytype_Event.Message.OneOf_Value
        var subject: PassthroughSubject<NSAttributedString, Never> = .init()
        
        func handleEvent(event: Event) {
            switch event {
            case let .blockSetText(value):
//                let attributedString = BlockModels.Parser.Text.AttributedText.Converter.asModel(text: value.text.value, marks: value.marks.value)
                // take from details and publish them.
                // get values and put them into page.
                // tell someone that you have new details.
//                self.subject.send(attributedString)
                return
            default:
              let logger = Logging.createLogger(category: .textBlocksViewsBase)
              os_log(.debug, log: logger, "We handle only events above. Event %@ isn't handled", String(describing: event))
                return
            }
        }
    }
}

// MARK: - ViewModel / Apply to model.
private extension Namespace.ViewModel {
    private func setModelData(text newText: String) {
        let theText = self.text
        self.text = theText

        return
        self.update { (block) in
            switch block.blockModel.information.content {
            case let .text(value):
                var value = value
//                value.text = newText
                var blockModel = block.blockModel
                blockModel.information.content = .text(value)
            default: return
            }
        }
    }
    func setModelData(attributedText: NSAttributedString) {
        
        // Update model.
        // Do we need to update model?
        self.update { (block) in
            switch block.blockModel.information.content {
            case let .text(value):
                var value = value
                value.attributedText = attributedText
                var blockModel = block.blockModel
                blockModel.information.content = .text(value)
            default: return
            }
        }
    }
    
    /// TODO: Move to appropriate event in event handler.
    /// We have event .blockSetAlignment, which must update model property alignment.
    ///
    func setModelData(alignment: NSTextAlignment) {
        
        return
        self.update { (block) in
            if let alignment = BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asModel(alignment) {
                var blockModel = block.blockModel
                blockModel.information.alignment = alignment
            }
        }
    }
    
    func apply(alignment: NSTextAlignment) -> AnyPublisher<Never, Error>? {
        self.setModelData(alignment: alignment)
        let block = self.getBlock()
        guard let contextID = block.findRoot()?.blockModel.information.id, case .text = block.blockModel.information.content else { return nil }
        return self.service.setAlignment.action(contextID: contextID, blockIds: [self.blockId], alignment: alignment)
    }
    func apply(attributedText: NSAttributedString) -> AnyPublisher<Never, Error>? {
        /// Do we need to update model?
        /// It will be updated on every blockShow event. ( BlockOpen command ).
        ///
        self.setModelData(attributedText: attributedText)
        
        let block = self.getBlock()
        
        guard let contextID = block.findRoot()?.blockModel.information.id, case .text = block.blockModel.information.content else { return nil }
        return self.service.setText.action(contextID: contextID, blockID: self.blockId, attributedString: attributedText)
    }
    func apply(update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value): self.setModelData(text: value)
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
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        func updateIfNeeded(textView: TextView.UIKitTextView?) {
            guard let textView = textView else { return }
            for view in self.textView.subviews {
                view.removeFromSuperview()
            }
            self.textView.addSubview(textView)
            let view = textView
            if let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        // MARK: Configured
        func configured(textView: TextView.UIKitTextView?) -> Self {
            self.updateIfNeeded(textView: textView)
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
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor),
                    view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
                    view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
                ])
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

        func updateIfNeeded(leftChild: UIView?) {
            guard let leftChild = leftChild else { return }
            self.topView.updateIfNeeded(leftViewSubview: leftChild, false)
            leftChild.translatesAutoresizingMaskIntoConstraints = false
            self.leftView = leftChild
            self.onLeftChildWillLayout(leftChild)
        }

        // MARK: Configured
        func configured(leftChild: UIView?) -> Self {
            self.updateIfNeeded(leftChild: leftChild)
            return self
        }

        func configured(textView: TextView.UIKitTextView?) -> Self {
            _ = self.topView.configured(textView: textView)
            return self
        }
        
        fileprivate func configured(_ resourceStream: AnyPublisher<Resource, Never>) -> Self {
            self.resourceSubscription = resourceStream.receive(on: RunLoop.main).sink { [weak self] (value) in            
                self?.backgroundColor = value.backgroundColor
            }
            return self
        }
    }
}

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.container == rhs.container
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.container)
        }
        
        // We need this comparison to compare if we need to update view or not.
        static func isPartialKindOf(_ lhs: Self, _ rhs: Self) -> Bool {
            lhs.contextMenuHolder?.makeDiffable() == rhs.contextMenuHolder?.makeDiffable()
        }
        
        static func isTextEqual(_ lhs: Self, _ rhs: Self) -> Bool {
            guard let left = lhs.contextMenuHolder?.getBlock().blockModel.information.content, let right = rhs.contextMenuHolder?.getBlock().blockModel.information.content else { return false }
            switch (left, right) {
            case let (.text(leftText), .text(rightText)): return leftText.attributedText == rightText.attributedText
            default: return false
            }
        }
        
        typealias HashableContainer = TopLevel.AliasesMap.BlockInformationUtilities.AsHashable
        var information: Information {
            self.container.value
        }
        private var container: HashableContainer
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
        init(_ information: Information) {
            /// We should warn if we have incorrect content type (?)
            /// Don't know :(
            /// Think about failable initializer
            
            switch information.content {
            case let .text(value) where value.contentType == .text: break
            default:
                let logger = Logging.createLogger(category: .textBlocksViewsBase)
                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
                break
            }
            
            self.container = .init(value: information)
        }
        
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            self.contextMenuHolder?.addContextMenu(view)
            return view
        }
        
        /// Hm, we could use state as from-user action channel.
        /// for example, if we have value "Checked"
        /// And we pressed something, we should do the following:
        /// We should pass value of state to a configuration.
        /// Next, configuration will send this value to a view model.
        /// Is it what we should use?
        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            /// do something
            return self
        }
        
        /// First Responder
        private var isPendingFirstResponder: Bool {
            self.contextMenuHolder?.getBlock().isFirstResponder ?? false
        }
        private func resolvePendingFirstResponder() {
            if let model = self.contextMenuHolder?.getBlock() {
                TopLevel.AliasesMap.BlockUtilities.FirstResponderResolver.resolvePendingUpdate(model)
            }
        }
        func resolvePendingFirstResponderIfNeeded() {
            if self.isPendingFirstResponder {
                self.resolvePendingFirstResponder()
            }
        }
    }
}

// MARK: - ContentView
private extension Namespace.ViewModel {
    class ContentView: UIView & UIContentView, DocumentModuleDocumentViewCellContentConfigurationsCellsListenerProtocol {
        
        struct Layout {
            let insets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView
        private var onLayoutSubviewsSubscription: AnyCancellable?
        
        /// Views
        var topView: TopView = .init()
        var contentView: UIView = .init()
        
        /// Subscriptions
        
        /// Others
//        var resource: Namespace.UIKitView.Resource = .init()
        var layout: Layout = .init()
                
        /// Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        private func setupUIElements() {
            /// Top most ContentView should have .translatesAutoresizingMaskIntoConstraints = true
            self.translatesAutoresizingMaskIntoConstraints = true

            [self.contentView, self.topView].forEach { (value) in
                value.translatesAutoresizingMaskIntoConstraints = false
            }
            
            _ = self.topView.configured(leftChild: .empty())
            
            /// View hierarchy
            self.contentView.addSubview(self.topView)
            self.addSubview(self.contentView)
        }
        
        private func addLayout() {
            if let superview = self.contentView.superview {
                let view = self.contentView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.insets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.insets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.insets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.insets.bottom),
                ])
            }
            
            if let superview = self.topView.superview {
                let view = self.topView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                ])
            }
        }
        
        /// Handle
        private func handle(_ value: Block.Content.ContentType.Text) {
            /// Do something
            /// We should reload data if text are not equal
            ///
        }
        
        /// Cleanup
        private func cleanupOnNewConfiguration() {
            /// Cleanup subscriptions.
        }
        
        /// Initialization
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// ContentView
        var currentConfiguration: ContentConfiguration!
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                /// apply configuration
                guard let configuration = newValue as? ContentConfiguration else { return }
                self.apply(configuration: configuration)
            }
        }

        init(configuration: ContentConfiguration) {
            super.init(frame: .zero)
            self.setup()
            self.apply(configuration: configuration)
        }
        
        private func apply(configuration: ContentConfiguration, forced: Bool) {
            if forced {
                self.currentConfiguration?.contextMenuHolder?.addContextMenu(self)
            }
        }
        
        private func apply(configuration: ContentConfiguration) {
            self.apply(configuration: configuration, forced: true)
            guard self.currentConfiguration != configuration else { return }
            
            self.currentConfiguration = configuration
            
            self.cleanupOnNewConfiguration()
            self.invalidateIntrinsicContentSize()
            
            self.applyNewConfiguration()
            self.topView.backgroundColor = .systemGray6
//            switch self.currentConfiguration.information.content {
//            case let .text(value): self.handle(value)
//            default: return
//            }
        }
        
        private func applyNewConfiguration() {
            _ = self.topView.configured(textView: self.currentConfiguration.contextMenuHolder?.getUIKitViewModel().createView())
        }
        
        /// MARK: - DocumentModuleDocumentViewCellContentConfigurationsCellsListenerProtocol
        private func onFirstResponder() {
            self.currentConfiguration.resolvePendingFirstResponderIfNeeded()
        }
        private func handle(_ value: DocumentModule.DocumentViewCells.ContentConfigurations.Table.Event) {
            switch value {
            case .shouldLayoutSubviews:
                self.onFirstResponder()
            }
        }
        func configure(publisher: AnyPublisher<DocumentModule.DocumentViewCells.ContentConfigurations.Table.Event, Never>) {
            if self.onLayoutSubviewsSubscription == nil {
                self.onLayoutSubviewsSubscription = publisher.sink(receiveValue: { [weak self] (value) in
                    self?.handle(value)
                })
            }
        }
    }
}
