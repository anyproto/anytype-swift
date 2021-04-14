import Foundation
import UIKit
import Combine
import os
import BlocksModels


// MARK: - ViewModel
extension BlocksViews.Page.Title {
    /// ViewModel for type `.link()` with style `.page`
    ///
    class ViewModel: BlocksViews.Page.Base.ViewModel {
        // Maybe we need also input and output subscribers.
        // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
        // We can't edit name of the block.
        // Add subscription on event.
        
        private var subscriptions: Set<AnyCancellable> = []
        private var textViewModel: TextView.UIKitTextView.ViewModel = .init()

        /// Points of truth.
        /// We could use it as input and output subscribers.
        /// For example, if user set value, it is going to `toModelTitle`.
        /// If value came from model, you set it to `toViewTitle`.
        @Published private var toViewTitle: String = "" // Maybe we should set here default value as "Untitled"

        /// Don't delete commented code.
        /// It is necessary to see what is wrong with it.
        /// We can't use `@Published` property, because its default value is `String.empty`.
        /// So, it will send value `String.empty` on new subscription. This is incorrect behaviour.
        /// It is better to `Passthrough` all data before user could change it.
        /// User could change data only when `View` has appeared.
        ///
        //        @Published private var toModelTitle: String = ""
        private var toModelTitleSubject: PassthroughSubject<String, Never> = .init()
        
        // MARK: - Placeholder
        lazy private var placeholder: NSAttributedString = {
            let text: NSString = "Untitled"
            let attributedString: NSMutableAttributedString = .init(string: text as String)
            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.preferredFont(forTextStyle: .title1)]
            attributedString.setAttributes(attributes, range: .init(location: 0, length: text.length))
            return attributedString
        }()
        
        // MARK: - Initialization
        override init(_ block: BlockModel) {
            super.init(block)
            self.setup(block: block)
        }

        // MARK: - Setup
        private func setupSubscribers() {
            // send value back to middleware
            /// As soon as we use this updatePublisher, we don't have cyclic updates.
            /// Explanation:
            /// TextStorage will send event to Coordinator
            /// Coordinator will send event to TextViewModel
            /// TextViewModel will send event to this ViewModel.
            /// This ViewModel will call Service.
            /// Service will update Model.
            /// Model will update PageDetailsViewModel.
            /// PageDetailsViewModel will send event to toViewText property.
            /// This property will send event to TextViewModel.
            /// TextViewModel will send event to TextView.
            /// TextView will send event to TextStorage.
            ///
            /// Cycle:
            /// TextStorage -> Coordinator -> TextViewModel -> ThisViewModel -> Service ->
            /// Model -> PageDetailsViewModel -> toViewText property -> TextViewModel -> TextView -> TextStorage
            ///
            /// BUT! (why does it work well)
            /// This publisher is binded to $text property of coordinator.
            /// This propeprty is not updated when update is coming from TextStorage.
            ///
            self.textViewModel.updatePublisher.sink { [weak self] (value) in
                switch value {
                case let .text(value): self?.toModelTitleSubject.send(value)
                default: return
                }
            }.store(in: &self.subscriptions)
                        
            self.$toViewTitle.removeDuplicates().receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.textViewModel.apply(update: .text(value))
            }.store(in: &self.subscriptions)
        }

        private func setup(block: BlockModel) {
            self.setupSubscribers()
            _ = self.textViewModel.configured(self)
        }
        
        // MARK: Subclassing / Events
        override func onIncoming(event: BlocksViews.Page.Base.Events) {
            switch event {
            case .pageDetailsViewModelDidSet:
                /// Here we must subscribe on values from this model and filter values.
                /// We only want values equal to details.
                ///
                self.pageDetailsViewModel?.wholeDetailsPublisher.map{ $0.title }
                    .sink(receiveValue: { [weak self] (value) in
                    value.flatMap({ self?.toViewTitle = $0.value })
                }).store(in: &self.subscriptions)

                self.toModelTitleSubject.notableError().flatMap({ [weak self] value in
                    self?.pageDetailsViewModel?.update(details: .title(.init(value: value))) ?? .empty()
                }).sink(receiveCompletion: { (value) in
                    switch value {
                    case .finished: return
                    case let .failure(error):
                        assertionFailure("PageBlocksViews title setDetails error has occured \(error)")
                    }
                }, receiveValue: {}).store(in: &self.subscriptions)
            }
        }

        // MARK: Subclassing / Views
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.textViewModel.createView(.init(liveUpdateAvailable: true)).configured(placeholder: .init(text: nil, attributedText: self.placeholder, attributes: [:])))
        }
    }
}

// MARK: - TextViewEvents
extension BlocksViews.Page.Title.ViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        switch action {
//        case let .addBlockAction(value):
//            switch value {
//            case .addBlock: self.send(userAction: .toolbars(.addBlock(.init(output: self.toolbarActionSubject))))
//            }
        
//        case .showMultiActionMenuAction(.showMultiActionMenu):
//            self.getUIKitViewModel().shouldResignFirstResponder()
//            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
            
        default: self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        }
    }
}


extension BlocksViews.Page.Title {
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

extension BlocksViews.Page.Title.State {
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
private extension BlocksViews.Page.Title {
    class UIKitView: UIView {
        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |

        var contentView: UIView!
        var topView: TopWithChildUIKitView!

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
                let view = TopWithChildUIKitView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            _ = self.topView.configured(leftChild: UIView.empty())

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

        // MARK: Configured
        func configured(textView: TextView.UIKitTextView?) -> Self {
            if let attributes = textView?.textView?.typingAttributes {
                var correctedAttributes = attributes
                correctedAttributes[.font] = UIFont.titleFont
                textView?.textView?.typingAttributes = correctedAttributes
            }
            _ = self.topView.configured(textView: textView)
            return self
        }
    }
}
