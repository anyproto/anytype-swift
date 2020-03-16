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

// MARK: - Base / BlockViewModel
extension TextBlocksViews {
    enum Base {
        class BlockViewModel: BlocksViews.Base.ViewModel {
            @Environment(\.developerOptions) var developerOptions
            private weak var delegate: TextBlocksViewsUserInteractionProtocol?
            
            private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
            
            private var inputSubscriber: AnyCancellable?
            private var outputSubscriber: AnyCancellable?
            
            @Published var text: String { willSet { self.objectWillChange.send() } }
            
            // MARK: Setup
            private func setupTextViewModel() {
                _ = self.textViewModel.configured(self)
                self.setupSubscribers()
            }
            private func setupSubscribers() {
                self.outputSubscriber = self.$text.map(TextView.UIKitTextView.ViewModel.Update.text).sink(receiveValue: {[weak self] value in self?.textViewModel.apply(update: value)})
                self.inputSubscriber = self.textViewModel.onUpdate.sink(receiveValue: {[weak self] value in self?.apply(update:value)})
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

// MARK: - ViewModel / Apply to model.
extension TextBlocksViews.Base.BlockViewModel {
    private func setModelData(text: String) {
        let theText = self.text
        self.text = theText
        
        self.update { (block) in
            switch block.information.content {
            case let .text(value):
                var value = value
                value.text = text
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

// MARK: - TextBlocksViewsUserInteractionProtocolHolder
extension TextBlocksViews.Base.BlockViewModel: TextBlocksViewsUserInteractionProtocolHolder {
    func configured(_ delegate: TextBlocksViewsUserInteractionProtocol?) -> Self? {
        self.delegate = delegate
        return self
    }
}

// MARK: - TextViewUserInteractionProtocol
extension TextBlocksViews.Base.BlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        self.delegate?.didReceiveAction(block: getRealBlock(), id: getID(), action: action)
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
