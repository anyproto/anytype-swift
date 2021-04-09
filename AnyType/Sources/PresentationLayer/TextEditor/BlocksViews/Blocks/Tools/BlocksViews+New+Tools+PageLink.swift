//
//  BlocksViews+New+Tools+PageLink.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine
import BlocksModels

fileprivate typealias Namespace = BlocksViews.Tools.PageLink

// MARK: - ViewModel
extension Namespace {
    /// ViewModel for type `.link()` with style `.page`
    /// Should we move it to PageBlocksViews? (?)
    ///
    final class ViewModel: BlocksViews.Tools.Base.ViewModel {
        // Maybe we need also input and output subscribers.
        // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
        // We can't edit name of the block.
        // Add subscription on event.
        private var subscriptions: Set<AnyCancellable> = []
        
        private var statePublisher: AnyPublisher<State, Never> = .empty()
        @Published private var state: State = .empty
        private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
        private var wholeDetailsViewModel: DetailsActiveModel = .init()
        
        func getDetailsViewModel() -> DetailsActiveModel { self.wholeDetailsViewModel }
        
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
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            if var configuration = ContentConfiguration(self.getBlock().blockModel.information) {
                configuration.contextMenuHolder = self
                return configuration
            }
            return super.makeContentConfiguration()
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

        // MARK: Contextual Menu
        override func makeContextualMenu() -> BlocksViews.ContextualMenu {
            .init(title: "", children: [
                .create(action: .general(.addBlockBelow)),
                .create(action: .specific(.turnInto)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .specific(.rename)),
                .create(action: .general(.moveTo)),
                .create(action: .specific(.backgroundColor)),
            ])
        }
    }
}

private extension Namespace.ViewModel {
    func applyOnUIView(_ view: Namespace.UIKitView) {
        _ = view.textView.configured(.init(liveUpdateAvailable: true))
        _ = view.textView.configured(self.textViewModel)
        _ = view.configured(stateStream: self.statePublisher).configured(state: self._state)
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
    func configured(_ publisher: AnyPublisher<DetailsActiveModel.PageDetails, Never>) -> Self {
        self.wholeDetailsViewModel.configured(publisher: publisher)
        self.wholeDetailsViewModel.wholeDetailsPublisher.map(Namespace.State.Converter.asOurModel).sink { [weak self] (value) in
            self?.state = value
        }.store(in: &self.subscriptions)
        return self
    }
}


// MARK: - Converter PageDetails to State
extension Namespace.State {
    enum Converter {
        static func asOurModel(_ pageDetails: DetailsInformationModelProtocol) -> BlocksViews.Tools.PageLink.State {
            let archived = false
            var hasContent = false
            let accessor = InformationAccessor.init(value: pageDetails)
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
        
        private enum Constants {
            static let imageViewWidth: CGFloat = 24
            static let textContainerInset: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
        }
        
        // MARK: Publishers
        private var subscriptions: Set<AnyCancellable> = []
        private var stateStream: AnyPublisher<State, Never> = .empty() {
            willSet {
                self.subscriptions = []
            }
            didSet {
                stateStream.receive(on: RunLoop.main).sink { [weak self] (value) in
                    self?.apply(value)
                }.store(in: &self.subscriptions)
            }
        }
        @Published private var state: State = .empty
        
        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |
        
        let topView: TopWithChildUIKitView = .init()
        let textView: TextView.UIKitTextView = {
            let placeholder = NSAttributedString(string: NSLocalizedString("Untitled", comment: ""),
                                                 attributes: [.foregroundColor: UIColor.secondaryTextColor,
                                                              .font: UIFont.bodyFont])
            let view = TextView.UIKitTextView()
            view.textView.update(placeholder: placeholder)
            return view
        }()
                
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
            self.self.topView.edgesToSuperview()
            self.apply(self.state)
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.topView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.topView)
            self.configured(textView: self.textView)
        }
                        
        // MARK: Configured
        func configured(textView: TextView.UIKitTextView?) {
            _ = self.topView.configured(textView: textView)
            textView?.textView.font = .bodyFont
            textView?.textView.typingAttributes = [.font: UIFont.bodyFont,
                                                   .foregroundColor: UIColor.textColor,
                                                   .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                   .underlineColor: UIColor.textColor]
            textView?.textView.textContainerInset = Constants.textContainerInset
            textView?.textView.defaultFontColor = .textColor
            textView?.textView?.isUserInteractionEnabled = false
        }
        
        func configured(stateStream: AnyPublisher<State, Never>) -> Self {
            self.stateStream = stateStream
            return self
        }
        
        func configured(state: Published<State>) -> Self {
            self._state = state
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
                
                let container = UIView()
                container.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(imageView)
                NSLayoutConstraint.activate([
                    container.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    container.widthAnchor.constraint(equalToConstant: Constants.imageViewWidth),
                    container.heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor),
                    container.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                ])
                return container
                
            case let .emoji(value):
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = value
                return label
            }
        }())
        self.textView.textView.text = state.title
    }
}

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.information == rhs.information
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.information)
        }
        
        var information: Information
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
        init?(_ information: Information) {
            switch information.content {
            case let .link(value) where value.style == .page:
                self.information = .init(information: information)
            default:
                return nil
            }
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
    final class ContentView: UIView & UIContentView {
        
        struct Layout {
            let insets: UIEdgeInsets = .init(top: 5, left: 20, bottom: 5, right: 20)
        }
        
        private let topView: Namespace.UIKitView = .init()
        private let layout: Layout = .init()
        private var currentConfiguration: ContentConfiguration
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                guard let configuration = newValue as? ContentConfiguration else { return }
                self.apply(configuration: configuration)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        init(configuration: ContentConfiguration) {
            self.currentConfiguration = configuration
            super.init(frame: .zero)
            self.setup()
            self.applyNewConfiguration()
        }
        
        /// Setup
        private func setup() {
            self.topView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.topView)
            self.topView.edgesToSuperview(insets: self.layout.insets)
        }
        
        private func apply(configuration: ContentConfiguration) {
            guard self.currentConfiguration != configuration else { return }
            self.currentConfiguration = configuration
            self.applyNewConfiguration()
        }
        
        private func applyNewConfiguration() {
            self.currentConfiguration.contextMenuHolder?.addContextMenuIfNeeded(self)
            self.currentConfiguration.contextMenuHolder?.applyOnUIView(self.topView)
        }
    }
}
