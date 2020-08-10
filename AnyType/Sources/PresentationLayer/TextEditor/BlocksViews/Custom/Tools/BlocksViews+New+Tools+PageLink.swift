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

// MARK: - ViewModel
extension Namespace {
    /// ViewModel for type `.link()` with style `.page`
    /// Should we move it to PageBlocksViews? (?)
    ///
    class ViewModel: BlocksViews.New.Tools.Base.ViewModel {
        typealias PageDetailsViewModel = DocumentModule.DocumentViewModel.PageDetailsViewModel
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
                .create(action: .specific(.color)),
                .init(payload: .init(), action: .specific(.backgroundColor))
                //.create(action: .specific(.backgroundColor)),
            ])
        }
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
        _ = self.wholeDetailsViewModel.configured(publisher: publisher)
        self.wholeDetailsViewModel.wholeDetailsPublisher.map(Namespace.State.Converter.from).sink { [weak self] (value) in
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
        static func from(_ pageDetails: DetailsInformationModelProtocol) -> BlocksViews.New.Tools.PageLink.State {
            let archived = false
            var hasContent = false
            let accessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor.init(value: pageDetails)
            let title = accessor.title?.text
            let emoji = accessor.iconEmoji?.text
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
            
            return self
        }
    }
}
