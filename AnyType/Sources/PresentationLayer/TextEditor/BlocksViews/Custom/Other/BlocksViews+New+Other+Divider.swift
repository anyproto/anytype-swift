//
//  BlocksViews+New+Other+Divider.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices

fileprivate typealias Namespace = BlocksViews.New.Other.Divider

private extension Logging.Categories {
    static let blocksViewsNewOtherDivider: Self = "BlocksViews.New.Other.Divider"
}

// MARK: ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.Other.Base.ViewModel {
                
        private var subscription: AnyCancellable?
        @Published private var statePublished: UIKitView.State?
        private var publisher: AnyPublisher<TopLevel.AliasesMap.BlockContent.Divider, Never> = .empty()
        
        override func makeUIView() -> UIView {
            UIKitView().configured(publisher: self.$statePublished.eraseToAnyPublisher())
        }
        
        // MARK: Subclassing
        override init(_ block: BlockModel) {
            super.init(block)
            self.setup()
        }
        
        // MARK: Subclassing / Events
        private func setup() {
            self.setupSubscribers()
        }
        
        func setupSubscribers() {
            let publisher = self.getBlock().didChangeInformationPublisher().map({ value -> TopLevel.AliasesMap.BlockContent.Divider? in
                switch value.content {
                case let .divider(value): return value
                default: return nil
                }
            }).safelyUnwrapOptionals().eraseToAnyPublisher()
            self.subscription = publisher.sink(receiveValue: { [weak self] (value) in
                let style = UIKitView.StateConverter.asOurModel(value.style)
                let state = style.flatMap(UIKitView.State.init)
                self?.statePublished = state
            })
        }
        
        override func makeDiffable() -> AnyHashable {
            let diffable = super.makeDiffable()
            if case let .divider(value) = self.getBlock().blockModel.information.content {
                let newDiffable: [String: AnyHashable] = [
                    "parent": diffable,
                    "dividerValue": value.style
                ]
                return .init(newDiffable)
            }
            return diffable
        }
        
        // MARK: Contextual Menu
        override func makeContextualMenu() -> BlocksViews.ContextualMenu {
            .init(title: "", children: [
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .specific(.turnInto)),
                .create(action: .general(.moveTo)),
            ])
        }
        
        override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
            switch contextualMenuAction {
            case .specific(.turnInto):
                let input: BlocksViews.UserAction.ToolbarOpenAction.TurnIntoBlock.Input = .init(payload: .init(filtering: .other([.divider, .dots])))
                self.send(userAction: .toolbars(.turnIntoBlock(.init(output: self.toolbarActionSubject, input: input))))
            default: super.handle(contextualMenuAction: contextualMenuAction)
            }
        }

    }
}

// MARK: - Conversion
private extension Namespace.UIKitView {
    struct StateConverter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Divider.Style
        typealias OurModel = State.Style
        
        static func asModel(_ value: OurModel) -> Model? {
            switch value {
            case .line: return .line
            case .dots: return .dots
            }
        }
        
        static func asOurModel(_ value: Model) -> OurModel? {
            switch value {
            case .line: return .line
            case .dots: return .dots
            }
        }
    }
}

// MARK: - UIView / Divider / Layout
private extension Namespace.UIKitViewWithDivider {
    struct Layout {
        var dividerViewInsets: UIEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        var dividerHeight: CGFloat = 2
    }
}

// MARK: - UIView / Divider / Resource
private extension Namespace.UIKitViewWithDivider {
    struct Resource {
        var dotsImagePath: String = "TextEditor/Style/Other/Divider/Dots"
    }
}

// MARK: - UIView / Divider
private extension Namespace {
    class UIKitViewWithDivider: UIView {
        var layout: Layout = .init()
        var resource: Resource = .init() {
            didSet {
//                self.placeholderLabel.text = self.resource.placeholderText
//                self.placeholderIcon.image = UIImage.init(named: self.resource.imagePath)
            }
        }
        
        // MARK: - Publishers
        private var subscription: AnyCancellable?
        @Published private var hasError: Bool = false
        
        // MARK: Views
        private var contentView: UIView!
        
        private var lineView: UIView!
        private var dotsView: UIView!
                
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
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.lineView = {
                let view = UIView()
                view.backgroundColor = .red
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.dotsView = {
                let view = UIView()
                view.backgroundColor = .green
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                        
            self.contentView.addSubview(self.lineView)
            self.contentView.addSubview(self.dotsView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.lineView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.heightAnchor.constraint(equalToConstant: self.layout.dividerHeight)
                ])
            }
            
            if let view = self.dotsView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.heightAnchor.constraint(equalToConstant: self.layout.dividerHeight)
                ])
            }
        }
        
        // MARK: - Actions
        func toDotsView() {
            self.lineView.isHidden = true
            self.dotsView.isHidden = false
        }
        
        func toLineView() {
            self.lineView.isHidden = false
            self.dotsView.isHidden = true
        }
        
        // MARK: - Configurations
        func configured(_ stream: Published<Bool>) {}
        
        func configured(_ resource: Resource) {
            self.resource = resource
        }
    }
}

// MARK: - UIView / Layout
private extension Namespace.UIKitView {
    struct Layout {}
}

// MARK: - UIView / State / Style
private extension Namespace.UIKitView {
    struct State {
        enum Style {
            case line, dots
        }
        
        var style: Style = .line
    }
}

// MARK: - UIView
private extension Namespace {
    
    class UIKitView: UIView {
        
        var subscription: AnyCancellable?
        var layout: Layout = .init()
        
        // MARK: Views
        var contentView: UIView!
        var dividerView: UIKitViewWithDivider!
        
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
            self.handle(.init())
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            // Default behavior
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.dividerView = {
                let view = UIKitViewWithDivider()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                        
            self.contentView.addSubview(self.dividerView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.dividerView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        func handle(_ state: State?) {
            switch state?.style {
            case .line: self.dividerView.toLineView()
            case .dots: self.dividerView.toDotsView()
            default: self.dividerView.toLineView()
            }
        }

        func configured(publisher: AnyPublisher<State?, Never>) -> Self {
            self.subscription = publisher.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (value) in
                self?.handle(value)
            })
            return self
        }
    }
}
