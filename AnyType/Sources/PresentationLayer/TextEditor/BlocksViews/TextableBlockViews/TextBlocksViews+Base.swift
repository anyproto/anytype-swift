//
//  TextBlocksViews+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import os

private extension Logging.Categories {
    static let textBlocksViewsBase: Self = "TextBlocksViews.Base"
}

// MARK: - Base / BlockViewModel
extension TextBlocksViews {
    enum Base {
        class BlockViewModel: BlocksViews.Base.ViewModel {
            @Environment(\.developerOptions) var developerOptions
            private weak var delegate: TextBlocksViewsUserInteractionProtocol?

            // for toggle and checkbox
            var getDelegate: TextBlocksViewsUserInteractionProtocol? { delegate }

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
            private var toModelTextSubject: PassthroughSubject<NSAttributedString, Never> = .init()
            
            private var eventListener: EventListener = .init()
            private var eventPublisher: NotificationEventListener<EventListener>?
            
            /// For OuterWorld.
            /// We should notify about user input.
            /// And here we have this publisher.
            ///
            var textDidChangePublisher: AnyPublisher<NSAttributedString, Never> = .empty()
            
            private var subscriptions: Set<AnyCancellable> = []

            // MARK: - Services
            private var service: TextBlockActionsService = .init()
            
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

            // MARK: Setup
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
                
                /// ToView
                self.$toViewText.safelyUnwrapOptionals().map(TextView.UIKitTextView.ViewModel.Update.attributedText).sink { [weak self] (value) in
                    self?.textViewModel.update = value
                }.store(in: &self.subscriptions)
                
                /// FromModel
                /// ???
                /// Actually, when we open page, we get BlockShow event.
                /// This event contains actual state of all blocks.
                
                /// ToModel
                self.toModelTextSubject.notableError().flatMap({ [weak self] (value) in
                    self?.apply(attributedText: value) ?? .empty()
                }).sink(receiveCompletion: { (value) in
                    switch value {
                    case .finished: return
                    case let .failure(error):
                        let logger = Logging.createLogger(category: .textBlocksViewsBase)
                        os_log(.debug, log: logger, "TextBlocksViews setBlockText error has occured. %@", String(describing: error))
                    }
                }, receiveValue: { _ in }).store(in: &self.subscriptions)
                
                /// Toolbar handling
                self.toolbarPassthroughSubject.sink { [weak self] (value) in
                    self?.handle(toolbarAction: value)
                }.store(in: &self.subscriptions)
                
                /// TextDidChange For OuterWorld
                self.textDidChangePublisher = self.textViewModel.richUpdatePublisher.map{ value -> NSAttributedString? in
                    switch value {
                    case let .attributedText(text): return text
                    default: return nil
                    }
                }.safelyUnwrapOptionals().eraseToAnyPublisher()
            }
            
            // MARK: - Events
            /// Setup function for events that are coming from middleware.
            /// It has distinct responsibility.
            private func setupEventListeners() {
                self.eventPublisher = NotificationEventListener(handler: self.eventListener)
                self.eventListener.subject.sink { [weak self] (value) in
                    self?.toViewText = value
                }.store(in: &self.subscriptions)
            }
            
            private func setup() {
                if self.developerOptions.current.debug.enabled {
                    self.text = Self.debugString(self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldHaveUniqueText, getID())
                    switch getRealBlock().information.content {
                    case let .text(blockType):
                        self.text = self.text + " >> " + blockType.text
                    default: return
                    }
                }
                else {
                    switch getRealBlock().information.content {
                    case let .text(blockType):
                        self.toViewText = blockType.attributedText
                    default: return
                    }
                }
                self.setupTextViewModel()
                self.setupSubscribers()
                self.setupEventListeners()
            }

            // MARK: Events
            private var toolbarPassthroughSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()
            private func handle(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
                let oldEvent = Converter.convert(newState: toolbarAction)
                self.didReceiveAction(generalAction: .textView(oldEvent))
            }

            // MARK: Subclassing
            override init(_ block: BlockModel) {
                super.init(block)
                self.setup()
            }

            // MARK: Subclassing accessors
            func getUIKitViewModel() -> TextView.UIKitTextView.ViewModel { self.textViewModel }

            override func makeUIView() -> UIView {
                self.getUIKitViewModel().createView()
            }
            
            // MARK: Contextual Menu
            override func makeContextualMenu() -> BlocksViews.ContextualMenu {
                .init(title: "", children: [
                    .create(action: .specific(.text(.turnInto))),
                    .create(action: .general(.delete)),
                    .create(action: .general(.duplicate)),
                    .create(action: .general(.moveTo)),
                    .create(action: .specific(.text(.style))),
                    .create(action: .specific(.text(.color))),
                    .create(action: .specific(.text(.backgroundColor))),
                ])
            }
            
            override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
                switch contextualMenuAction {
                case let .general(value):
                    switch value {
                    case .delete: self.toolbarPassthroughSubject.send(.editBlock(.delete))
                    case .duplicate: self.toolbarPassthroughSubject.send(.editBlock(.duplicate))
                    case .moveTo: break
                    }
                case let .specific(.text(value)):
                    switch value {
                    case .turnInto: self.send(userAction: .toolbars(.turnIntoBlock(self.toolbarPassthroughSubject)))
                    case .style: break
                    case .color: self.send(userAction: .toolbars(.setTextColor(self.toolbarPassthroughSubject)))
                    case .backgroundColor: self.send(userAction: .toolbars(.setBackgroundColor(self.toolbarPassthroughSubject)))
                    }
                default: return
                }
            }

            // MARK: Empty
            static let empty = BlockViewModel.createEmptyBlock()
        }
    }
}

// MARK: - Events
private extension TextBlocksViews.Base.BlockViewModel {
    class EventListener: EventHandler {
        typealias Event = Anytype_Event.Message.OneOf_Value
        var subject: PassthroughSubject<NSAttributedString, Never> = .init()
        
        func handleEvent(event: Event) {
            switch event {
            case let .blockSetText(value):
                let attributedString = BlockModels.Parser.Text.AttributedText.Converter.asModel(text: value.text.value, marks: value.marks.value)
                // take from details and publish them.
                // get values and put them into page.
                // tell someone that you have new details.
                self.subject.send(attributedString)
            default:
              let logger = Logging.createLogger(category: .textBlocksViewsBase)
              os_log(.debug, log: logger, "We handle only events above. Event %@ isn't handled", String(describing: event))
                return
            }
        }
    }
}

// MARK: - Convenient emptyBlock
private extension TextBlocksViews.Base.BlockViewModel {
    static func createEmptyBlock() -> TextBlocksViews.Base.BlockViewModel {
        let informationValue = Block.mockText(.text)
        let information = BlockModels.Block.Information.init(id: informationValue.id, content: informationValue.content)
        let block: BlockModel = .init(indexPath: .init(), blocks: [])
        block.information = information
        return .init(block)
    }
}

// MARK: - Converter ( To Delete )
private extension TextBlocksViews.Base.BlockViewModel {
    enum Converter {
        private static func convert(newState: BlocksViews.Toolbar.UnderlyingAction.BlockType) -> TextView.UserAction.BlockAction.BlockType {
            let logger = Logging.createLogger(category: .textBlocksViewsBase)
            os_log(.debug, log: logger, "Do not use this method later. It is deprecated. Remove it when you are ready.")
            switch newState {
            case let .text(value):
                switch value {
                case .text: return .text(.text)
                case .h1: return .text(.h1)
                case .h2: return .text(.h2)
                case .h3: return .text(.h3)
                case .highlighted: return .text(.highlighted)
                }
            case let .list(value):
                switch value {
                case .bulleted: return .list(.bulleted)
                case .checkbox: return .list(.checkbox)
                case .numbered: return .list(.numbered)
                case .toggle: return .list(.toggle)
                }
            case let .page(value):
                switch value {
                case .page: return .tool(.page)
                case .existingPage: return .tool(.existingTool)
                }
            case let .media(value):
                switch value {
                case .file: return .media(.file)
                case .picture: return .media(.picture)
                case .video: return .media(.video)
                case .bookmark: return .media(.bookmark)
                case .code: return .media(.code)
                }
            case let .tool(value):
                switch value {
                case .contact: return .tool(.contact)
                case .database: return .tool(.database)
                case .set: return .tool(.set)
                case .task: return .tool(.task)
                }
            case let .other(value):
                switch value {
                case .divider: return .other(.divider)
                case .dots: return .other(.divider)
                }
            }
        }
        static func convert(newState: BlocksViews.Toolbar.UnderlyingAction) -> TextView.UserAction {
            switch newState {
            case let .addBlock(value): return .blockAction(.addBlock(convert(newState: value)))
            case let .turnIntoBlock(value): return .blockAction(.turnIntoBlock(convert(newState: value)))
            case let .changeColor(value):
                switch value {
                case let .textColor(value): return .blockAction(.changeColor(.textColor(value)))
                case let .backgroundColor(value): return .blockAction(.changeColor(.backgroundColor(value)))
                }
            case let .editBlock(value):
                switch value {
                case .delete: return .blockAction(.editBlock(.delete))
                case .duplicate: return .blockAction(.editBlock(.duplicate))
                }
            }
        }
    }
}

// MARK: - ViewModel / Apply to model.
private extension TextBlocksViews.Base.BlockViewModel {
    private func setModelData(text newText: String) {
        let theText = self.text
        self.text = theText

        return
        self.update { (block) in
            switch block.information.content {
            case let .text(value):
                var value = value
//                value.text = newText
                block.information.content = .text(value)
            default: return
            }
        }
    }
    func setModelData(attributedText: NSAttributedString) {
        
        // Update model.
        // Do we need to update model?
        self.update { (block) in
            switch block.information.content {
            case let .text(value):
                var value = value
                value.attributedText = attributedText
                block.information.content = .text(value)
            default: return
            }
        }
    }
    func apply(attributedText: NSAttributedString) -> AnyPublisher<Never, Error>? {
        /// Do we need to update model?
        /// It will be updated on every blockShow event. ( BlockOpen command ).
        ///
        let block = self.getRealBlock()
        guard let contextID = block.findRoot()?.information.id, case let .text(value) = block.information.content else { return nil }
        return self.service.setText.action(contextID: contextID, blockID: self.blockId, attributedString: attributedText)
    }
    func apply(update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value): self.setModelData(text: value)
        case let .attributedText(value): return self.setModelData(attributedText: value)
        }
    }
}

// MARK: - Focus
extension TextBlocksViews.Base.BlockViewModel {
    func set(focus: Bool) {
        self.textViewModel.shouldSetFocus = focus
    }
}

// MARK: - TextBlocksViewsUserInteractionProtocolHolder
// Should we still keep this protocol? It is bad for our purposes.
extension TextBlocksViews.Base.BlockViewModel: TextBlocksViewsUserInteractionProtocolHolder {
    func configured(_ delegate: TextBlocksViewsUserInteractionProtocol?) -> Self? {
        self.delegate = delegate
        return self
    }
}

// MARK: - Convenient UserInteraction
extension TextBlocksViews.Base.BlockViewModel {
    func didReceiveAction(generalAction action: TextBlocksViews.UserInteraction) {
        self.delegate?.didReceiveAction(block: getRealBlock(), id: getID(), generalAction: action)
    }
}

// MARK: - TextViewUserInteractionProtocol
extension TextBlocksViews.Base.BlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        switch action {
        case let .addBlockAction(value):
            switch value {
            case .addBlock: self.send(userAction: .toolbars(.addBlock(self.toolbarPassthroughSubject)))
            }
        default: self.delegate?.didReceiveAction(block: getRealBlock(), id: getID(), action: action)
        }
    }
}

// MARK: - Debug
extension TextBlocksViews.Base.BlockViewModel {
    // Class scope, actually.
    class func debugString(_ unique: Bool, _ id: BlockModelID) -> String {
        unique ? self.defaultDebugStringUnique(id) : self.defaultDebugString()
    }
    class func defaultDebugStringUnique(_ id: BlockModelID) -> String {
        self.defaultDebugString() + id.description.prefix(10)
    }
    class func defaultDebugString() -> String {
        .init("\(String(reflecting: self))".split(separator: ".").dropLast().last ?? "")
    }
}

// MARK: - UIKitView / TopView
extension TextBlocksViews.Base {
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
extension TextBlocksViews.Base {
    class TopWithChildUIKitView: UIView {
        // TODO: Refactor
        // OR
        // We could do it on toggle level or on block parsing level?
        struct Layout {
            var containedViewInset = 8
            var indentationWidth = 8
            var boundaryWidth = 2
        }

        // MAKR:

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
    }
}
