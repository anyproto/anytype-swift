//
//  ToolsBlocksViews+PageLink.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os

// MARK: - ViewModel
extension ToolsBlocksViews.PageLink {
    /// ViewModel for type `.link()` with style `.page`
    ///
    class BlockViewModel: ToolsBlocksViews.Base.BlockViewModel {
        // Maybe we need also input and output subscribers.
        // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
        // We can't edit name of the block.
        // Add subscription on event.
        private var subscriptions: Set<AnyCancellable> = []
        
        private var statePublisher: AnyPublisher<State, Never> = .empty()
        @Published private var state: State = .empty
        private var eventListener: EventListener = .init()
        private var eventPublisher: NotificationEventListener<EventListener>?
        private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
        
        override init(_ block: BlocksViews.Base.ViewModel.BlockModel) {
            super.init(block)
            self.setup(block: block)
        }
        
        private func setup(block: BlocksViews.Base.ViewModel.BlockModel) {
            let information = block.information
            switch information.content {
            case let .link(value):
                switch value.style {
                case .page:
                    let pageId = value.targetBlockID // do we need it?
                    self.eventPublisher = NotificationEventListener(handler: self.eventListener)
                    self.statePublisher = self.eventListener.$state.safelyUnwrapOptionals().eraseToAnyPublisher()
                    self.statePublisher.sink { [weak self] (value) in
                        self?.state = value
                    }.store(in: &self.subscriptions)
                    
                default: return
                }
            default: return
            }
        }
        
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.textViewModel.createView())
                .configured(stateStream: self.statePublisher)
                .configured(state: self._state)
        }
    }
}

// MARK: - Events
private extension Logging.Categories {
  static let eventHandler: Self = "Presentation.TextEditor.BlocksViews.Tools.PageLink.EventHandler"
}

private extension ToolsBlocksViews.PageLink {
    /// Since we need to update a link of page, we should listen for events that are coming from middleware.
    /// Thus, if we update page, all links to this page must be updated.
    /// For that we use `EventListener` that will select necessary events.
    /// It will extract data from events and send to view model of `.link` with style `.page`.
    ///
    class EventListener: EventHandler {
        typealias Event = Anytype_Event.Message.OneOf_Value

        @Published var state: State?
        
        func handleEvent(event: Event) {
            switch event {
//            case let .blockSetDetails(value):
            case let .blockShow(value):
                // take from details and publish them.
                // get values and put them into page.
//
                break
//            case let .blockSetLink(value):
//                break
            default:
              let logger = Logging.createLogger(category: .eventHandler)
              os_log(.debug, log: logger, "We handle only events above. Event %@ isn't handled", String(describing: event))
                return
            }
        }
    }
}

// MARK: - State
extension ToolsBlocksViews.PageLink {
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

extension ToolsBlocksViews.PageLink.State {
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
private extension ToolsBlocksViews.PageLink {
    class UIKitView: UIView {
        typealias TopView = TextBlocksViews.Base.TopWithChildUIKitView
        
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
            _ = self.topView.configured(textView: textView)
            let text: NSString = "Untitled"
            let attributedString: NSMutableAttributedString = .init(string: text as String)
            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.preferredFont(forTextStyle: .title3)]
            attributedString.setAttributes(attributes, range: .init(location: 0, length: text.length))
            textView?.getTextView?.textStorage.setAttributedString(attributedString)
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
