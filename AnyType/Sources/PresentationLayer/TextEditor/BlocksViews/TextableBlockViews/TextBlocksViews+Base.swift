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

            private var inputSubscriber: AnyCancellable?
            private var outputSubscriber: AnyCancellable?

            private var toolbarSubscriber: AnyCancellable?

            @Published var text: String { willSet { self.objectWillChange.send() } }

            // MARK: Setup
            private func setupTextViewModel() {
                _ = self.textViewModel.configured(self)
                self.setupSubscribers()
            }
            private func setupSubscribers() {
                self.outputSubscriber = self.$text.map(TextView.UIKitTextView.ViewModel.Update.text).sink(receiveValue: {[weak self] value in self?.textViewModel.apply(update: value)})
                self.inputSubscriber = self.textViewModel.onUpdate.sink(receiveValue: {[weak self] value in self?.apply(update:value)})
                self.toolbarSubscriber = self.toolbarPassthroughSubject.sink { [weak self] (value) in
                    self?.process(toolbarAction: value)
                }
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
                        self.text = blockType.text
                    default: return
                    }
                }
                self.setupTextViewModel()
            }

            // MARK: Events
            private var toolbarPassthroughSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()
            private func process(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
                let oldEvent = Converter.convert(newState: toolbarAction)
                self.didReceiveAction(generalAction: .textView(oldEvent))
            }

            // MARK: Subclassing
            override init(_ block: BlockModel) {
                self.text = ""
                super.init(block)
                self.setup()
            }

            private static func createEmptyBlock() -> BlockViewModel {
                let informationValue = Block.mockText(.text)
                let information = BlockModels.Block.Information.init(id: informationValue.id, content: informationValue.content)
                let block: BlockModel = .init(indexPath: .init(), blocks: [])
                block.information = information
                return BlockViewModel.init(block)
            }

            // MARK: Subclassing accessors
            func getUIKitViewModel() -> TextView.UIKitTextView.ViewModel { self.textViewModel }

            override func makeUIView() -> UIView {
                self.getUIKitViewModel().createView()
            }

            // MARK: Empty
            static let empty = BlockViewModel.createEmptyBlock()
        }
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
            }
        }
    }
}

// MARK: - ViewModel / Apply to model.
extension TextBlocksViews.Base.BlockViewModel {
    private func setModelData(text newText: String) {
        let theText = self.text
        self.text = theText

        self.update { (block) in
            switch block.information.content {
            case let .text(value):
                var value = value
                value.text = newText
                block.information.content = .text(value)
            default: return
            }
        }
    }
    func apply(update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value): self.setModelData(text: value)
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
            case .addBlock: self.send(userAction: .toolbars(.addBlockWithPassthroughSubject(self.toolbarPassthroughSubject)))
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
