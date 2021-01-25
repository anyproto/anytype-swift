//
//  BlocksViews+New+Tools+PageLink.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.Tools.PageLink

private extension Logging.Categories {
    static let blocksViewsNewToolsPageLink: Self = "BlocksViews.New.Tools.PageLink"
}

// MARK: - ViewModel
extension Namespace {
    /// ViewModel for type `.link()` with style `.page`
    /// Should we move it to PageBlocksViews? (?)
    ///
    class ViewModel: BlocksViews.New.Tools.Base.ViewModel {
        typealias PageDetailsViewModel = EditorModule.Document.ViewController.ViewModel.PageDetailsViewModel
        // Maybe we need also input and output subscribers.
        // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
        // We can't edit name of the block.
        // Add subscription on event.
        private var subscriptions: Set<AnyCancellable> = []
        
        private var statePublisher: AnyPublisher<State, Never> = .empty()
        @Published private var state: State = .empty
        private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
        private var wholeDetailsViewModel: PageDetailsViewModel = .init()
        
        func getDetailsViewModel() -> PageDetailsViewModel { self.wholeDetailsViewModel }
        
        lazy private var placeholder: NSAttributedString = {
            let text: NSString = "Untitled"
            let attributedString: NSMutableAttributedString = .init(string: text as String)
            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.preferredFont(forTextStyle: .title3)]
            attributedString.setAttributes(attributes, range: .init(location: 0, length: text.length))
            return attributedString
        }()
        
        override init(_ block: BlockModel) {
            super.init(block)
            self.setup(block: block)
        }
        
        private func setup(block: BlockModel) {
            let information = block.blockModel.information
            switch information.content {
            case let .link(value):
                switch value.style {
                case .page:
                    let pageId = value.targetBlockID // do we need it?
                    _ = self.wholeDetailsViewModel.configured(documentId: pageId)
                    
                    /// One possible way to do it is to get access to a container in flattener.
                    /// Possible (?)
                    /// OR
                    /// We could set container to all page links when we parsing data.
                    /// We could add additional field which stores publisher.
                    /// In this case we move whole notification logic into model.
                    /// Well, not so bad (?)
                    
                    self.$state.map(\.title).safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
                        self?.textViewModel.update = .text(value)
                    }.store(in: &self.subscriptions)
                    
                    self.statePublisher = self.$state.eraseToAnyPublisher()
                default: return
                }
            default: return
            }
        }
        
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.textViewModel.createView(.init(liveUpdateAvailable: true)).configured(placeholder: .init(text: nil, attributedText: self.placeholder, attributes: [:])))
                .configured(stateStream: self.statePublisher)
                .configured(state: self._state)
        }
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
        }
        
        override func handle(event: BlocksViews.UserEvent) {
            switch event {
            case .didSelectRowInTableView:
                switch self.getBlock().blockModel.information.content {
                case let .link(value):
                    self.send(userAction: .specific(.tool(.pageLink(.shouldShowPage(value.targetBlockID)))))
                default: return
                }
            }
        }
//
//        // Add diffable to update changes.
//        override func makeDiffable() -> AnyHashable {
//            let diffable = super.makeDiffable()
//            if case let .link(value) = self.getBlock().blockModel.information.content {
//                let newDiffable: [String: AnyHashable] = [
//                    "parent": diffable,
////                    "style": AnyHashable(self.state)
//                ]
//                return .init(newDiffable)
//            }
//            return diffable
//        }
        

        // MARK: Contextual Menu
        override func makeContextualMenu() -> BlocksViews.ContextualMenu {
            .init(title: "", children: [
                .create(action: .general(.addBlockBelow)),
                .create(action: .specific(.turnInto)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .specific(.rename)),
                .create(action: .general(.moveTo)),
                .create(action: .specific(.color)),
                .init(payload: .init(), action: .specific(.backgroundColor))
                //.create(action: .specific(.backgroundColor)),
            ])
        }
    }
}

private extension Namespace.ViewModel {
    func applyOnUIView(_ view: Namespace.UIKitView) -> UIView {
        view.configured(textView: self.textViewModel.createView(.init(liveUpdateAvailable: true)).configured(placeholder: .init(text: nil, attributedText: self.placeholder, attributes: [:])))
            .configured(stateStream: self.statePublisher)
            .configured(state: self._state)
    }
}

// MARK: - Configurations
extension Namespace.ViewModel {
    /// NOTES:
    /// Look at this method carefully.
    /// We have to pass publisher for `self.wholeDetailsViewModel`.
    /// Why so?
    ///
    /// Short story: Link should listen their own Details publisher.
    ///
    /// Long story:
    /// `BlockShow` will send details for open page with title and with icon.
    /// These details are shown on page itself.
    ///
    /// But it also contains `details` for all `links` that this page `contains`.
    ///
    /// So, if you change `details` or `title` of a `page` that this `link` is point to, so, all opened pages with link to changed page will receive updates.
    ///
    func configured(_ publisher: AnyPublisher<PageDetailsViewModel.PageDetails, Never>) -> Self {
        self.wholeDetailsViewModel.configured(publisher: publisher)
        self.wholeDetailsViewModel.wholeDetailsPublisher.map(Namespace.State.Converter.asOurModel).sink { [weak self] (value) in
            self?.state = value
        }.store(in: &self.subscriptions)
        return self
    }
}

// MARK: - Events
private extension Logging.Categories {
  static let eventHandler: Self = "Presentation.TextEditor.BlocksViews.Tools.PageLink.EventHandler"
}

// MARK: - Converter PageDetails to State
extension Namespace.State {
    enum Converter {
        typealias T = TopLevel.AliasesMap
        typealias Model = DetailsInformationModelProtocol
        typealias OurModel = BlocksViews.New.Tools.PageLink.State
        static func asOurModel(_ pageDetails: Model) -> OurModel {
            let archived = false
            var hasContent = false
            let accessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor.init(value: pageDetails)
            let title = accessor.title?.value
            let emoji = accessor.iconEmoji?.value
            hasContent = emoji != nil
            let correctEmoji = emoji.flatMap({$0.isEmpty ? nil : $0})
            return .init(archived: archived, hasContent: hasContent, title: title, emoji: correctEmoji)
        }
    }
}

// MARK: - State
extension Namespace {
    /// Struct State that will take care of all flags and data.
    /// It is equal semantically to `Payload` that will delivered from outworld ( view model ).
    /// It contains necessary information for view as emoji, title, archived, etc.
    ///
    struct State {
        static let empty = State.init(archived: false, hasContent: false, title: nil, emoji: nil)
        var archived: Bool
        var hasContent: Bool
        var title: String?
        var emoji: String?
        
        var style: Style {
            switch (hasContent, emoji) {
            case (false, .none): return .noContent
            case (true, .none): return .noEmoji
            case let (_, .some(value)): return .emoji(value)
            }
        }
    }
}

extension Namespace.State {
    /// Visual style of left view ( image or label with emoji ).
    enum Style {
        typealias Emoji = String
        case noContent
        case noEmoji
        case emoji(Emoji)
        var resource: String {
            switch self {
            case .noContent: return "TextEditor/Style/Page/empty"
            case .noEmoji: return "TextEditor/Style/Page/withoutEmoji"
            case let .emoji(value): return value
            }
        }
    }
}

// MARK: - UIView
private extension Namespace {
    class UIKitView: UIView {
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView
        
        // MARK: Publishers
        private var subscriptions: Set<AnyCancellable> = []
        private var stateStream: AnyPublisher<State, Never> = .empty() {
            willSet {
                self.subscriptions = []
            }
            didSet {
                stateStream.receive(on: RunLoop.main).sink { [weak self] (value) in
                    _ = self?.update(state: value)
                }.store(in: &self.subscriptions)
            }
        }
        @Published private var state: State = .empty
        
        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |
        
        var contentView: UIView!
        var topView: TopView!
                
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
            self.updateToEmptyView()
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
                let view = TopView()
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
        func updateToEmptyView() {
            // CAUTION! Set everything to empty state. ( Is it ok? )
            // Add Published variable?
            _ = self.update(state: self.state)
        }
                        
        // MARK: Configured
        func configured(textView: TextView.UIKitTextView?) -> Self {
            if let attributes = textView?.getTextView?.typingAttributes {
                var correctedAttributes = attributes
                correctedAttributes[.font] = UIFont.preferredFont(forTextStyle: .title3)
                textView?.getTextView?.typingAttributes = correctedAttributes
                
                let text = textView?.getTextView?.text ?? ""
                let attributedString: NSMutableAttributedString = .init(string: text, attributes: correctedAttributes)
                textView?.getTextView?.textStorage.setAttributedString(attributedString)
            }
            _ = self.topView.configured(textView: textView)
            textView?.getTextView?.isUserInteractionEnabled = false
            return self
        }
        
        func configured(stateStream: AnyPublisher<State, Never>) -> Self {
            self.stateStream = stateStream
            return self
        }
        
        func configured(state: Published<State>) -> Self {
            self._state = state
            return self
        }
                
        // MARK: Update State
        func update(state: State) -> Self {
            self.apply(state)
            return self
        }
    }
}

extension Namespace.UIKitView {
    func apply(_ state: Namespace.State) {
        _ = self.topView.configured(leftChild: {
            switch state.style {
            case .noContent, .noEmoji:
                let imageView = UIImageView(image: UIImage(named: state.style.resource))
                imageView.translatesAutoresizingMaskIntoConstraints = false
                return imageView
                
            case let .emoji(value):
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = value
                return label
            }
        }())
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
            case let .link(value) where value.style == .page: break
            default:
                let logger = Logging.createLogger(category: .blocksViewsNewToolsPageLink)
                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
                break
            }
            
            self.container = .init(value: information)
        }
        
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            self.contextMenuHolder?.addContextMenuIfNeeded(view)
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
        
        struct Layout {
            let insets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        typealias TopView = Namespace.UIKitView
        
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
                self.currentConfiguration?.contextMenuHolder?.addContextMenuIfNeeded(self)
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
            _ = self.currentConfiguration.contextMenuHolder?.applyOnUIView(self.topView)
        }
    }
}
