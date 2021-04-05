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
        private var publisher: AnyPublisher<TopLevel.BlockContent.Divider, Never> = .empty()
        
        override func makeUIView() -> UIView {
            UIKitView().configured(publisher: self.$statePublished.eraseToAnyPublisher())
        }
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
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
            let publisher = self.getBlock().didChangeInformationPublisher().map({ value -> TopLevel.BlockContent.Divider? in
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
                .create(action: .general(.addBlockBelow)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .specific(.turnInto)),
                .create(action: .general(.moveTo)),
            ])
        }
        
        override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
            switch contextualMenuAction {
            case .specific(.turnInto):
                let input: BlocksViews.UserAction.ToolbarOpenAction.TurnIntoBlock.Input = .init(payload: .init(filtering: .other([.lineDivider, .dotsDivider])))
                self.send(userAction: .toolbars(.turnIntoBlock(.init(output: self.toolbarActionSubject, input: input))))
            default: super.handle(contextualMenuAction: contextualMenuAction)
            }
        }

    }
}

// MARK: - Conversion
private extension Namespace.UIKitView {
    struct StateConverter {
        typealias Model = TopLevel.BlockContent.Divider.Style
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
        private var dotsImageViews: [UIImageView] = []
                
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
                view.backgroundColor = .lightGray
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.dotsView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                /// Add imageViews
                let image: UIImage? = UIImage.init(named: self.resource.dotsImagePath)
                let leftImageView: UIImageView = .init(image: image)
                let centerImageView: UIImageView = .init(image: image)
                let rightImageView: UIImageView = .init(image: image)
                
                for view in [leftImageView, centerImageView, rightImageView] {
                    view.contentMode = .center
                    view.translatesAutoresizingMaskIntoConstraints = false
                }
                
                view.addSubview(leftImageView)
                view.addSubview(centerImageView)
                view.addSubview(rightImageView)
                
                self.dotsImageViews = [leftImageView, centerImageView, rightImageView]
                
//                if let superview = centerImageView.superview {
//                    NSLayoutConstraint.activate([
//                        view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
//                        view.topAnchor.constraint(equalTo: superview.topAnchor),
//                        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
//                    ])
//                }
//
//                if let superview = leftImageView.superview {
//                    let rightView = centerImageView
//                    NSLayoutConstraint.activate([
//                        view.topAnchor.constraint(equalTo: superview.topAnchor),
//                        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
//                        view.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor),
//                        view.trailingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: -10)
//                    ])
//                }
//
//                if let superview = rightImageView.superview {
//                    let leftView = centerImageView
//                    NSLayoutConstraint.activate([
//                        view.topAnchor.constraint(equalTo: superview.topAnchor),
//                        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
//                        view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: 10),
//                        view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor)
//                    ])
//                }

                
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
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.dividerViewInsets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.dividerViewInsets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.dividerViewInsets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.dividerViewInsets.bottom)
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
            
            let leftImageView = self.dotsImageViews[0]
            let centerImageView = self.dotsImageViews[1]
            let rightImageView = self.dotsImageViews[2]
            
            if let superview = centerImageView.superview {
                let view = centerImageView
                NSLayoutConstraint.activate([
                    view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let superview = leftImageView.superview {
                let view = leftImageView
                let rightView = centerImageView
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: -10)
                ])
            }
            
            if let superview = rightImageView.superview {
                let view = rightImageView
                let leftView = centerImageView
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: 10),
                    view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor)
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

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
    /// As soon as we have builder in this type ( makeContentView )
    /// We could map all states ( for example, image has several states ) to several different ContentViews.
    ///
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.information == rhs.information
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.information)
        }
        
        var information: Information
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
        init(_ information: Information) {
            /// We should warn if we have incorrect content type (?)
            /// Don't know :(
            /// Think about failable initializer
            
            switch information.content {
            case .divider: break
            default:
                let logger = Logging.createLogger(category: .blocksViewsNewOtherDivider)
                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
                break
            }
            
            self.information = .init(information: information)
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
//            self.contextMenuHolder?.addContextMenu(view)
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
    }
}


// MARK: - ContentView
private extension Namespace.ViewModel {
    class ContentView: UIView & UIContentView {
        
        private var subscription: AnyCancellable?
        private var layout: Namespace.UIKitView.Layout = .init()
        
        // MARK: Views
        private var contentView: UIView = .init()
        private var dividerView: Namespace.UIKitViewWithDivider = .init()
                
        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            // Default behavior
            [self.contentView, self.dividerView].forEach { view in
                view.translatesAutoresizingMaskIntoConstraints = false
            }
                        
            self.contentView.addSubview(self.dividerView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let superview = self.contentView.superview {
                let view = self.contentView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }

            if let superview = self.dividerView.superview {
                let view = self.dividerView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        func handle(_ state: Namespace.UIKitView.State) {
            switch state.style {
            case .line: self.dividerView.toLineView()
            case .dots: self.dividerView.toDotsView()
            }
        }
        
        /// Initialization
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// ContentView
        func cleanupOnNewConfiguration() {
            // do nothing or something?
        }
        
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
                self.currentConfiguration?.contextMenuHolder?.addContextMenuIfNeeded(self)
            }
        }
        
        private func apply(configuration: ContentConfiguration) {
            guard self.currentConfiguration != configuration else {
                self.apply(configuration: configuration, forced: true)
                return
            }
            
            self.currentConfiguration = configuration
            self.apply(configuration: configuration, forced: true)
            
            self.cleanupOnNewConfiguration()
            switch self.currentConfiguration.information.content {
            case let .divider(value):
                guard let style = Namespace.UIKitView.StateConverter.asOurModel(value.style) else {
                    return
                }
                self.handle(.init(style: style))
            default: return
            }
        }
    }
}
