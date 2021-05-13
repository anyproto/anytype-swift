import Foundation
import UIKit
import Combine
import os
import BlocksModels


class BlockTextView: UIView {
    // MARK: Options ( From Developers To Managers ONLY )
    struct Options {
        /// Well, we still don't have correct handling of input data.
        /// We should assure ourselves, that our data will be handled correctly.
        /// Read about usage of this flag below.
        var liveUpdateAvailable: Bool
    }

    // MARK: Combine
    private var subscriptions: Set<AnyCancellable> = []

    private var options: Options = .init(liveUpdateAvailable: false)

    // MARK: ViewModel
    weak var model: BlockTextViewModel?
    private var builder: BlockTextViewBuilder = .init()

    // MARK: Views
    private var contentView: UIView!
    var textView: TextViewWithPlaceholder!

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUIElements()
        self.addLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func update(placeholder: Placeholder) {
        self.textView?.update(placeholder: placeholder.placeholder)
    }

    // MARK: Setup Interactions
    private func setupInteractions() {

        /// TODO: Fix it.
        /// It will be correct after we get it right after Marks PR.
        ///
        /// We could store this into subscription `IF ONLY` we assure ourselves, that text in this field will be handled correctly.
        ///

        /// TODO: Add async if needed.
        /// For example, `.receive(on: )` will make invocation `async`.
        /// Read carefully the code below.
        ///
        /// Whenever `self.model.update` property is changed, it will __simultaneously__ and __synchronically__ call `.sink`
        ///
        /// So, if you want real "async" api, you need to configure these subscriptions correctly.
        ///
        if self.options.liveUpdateAvailable {
            self.model?.$update
                .sink { [weak self] value in
                    self?.onUpdate(value)
                }
                .store(in: &self.subscriptions)
        }
        else {
            /// We don't store this subscription _intentionally_.
            _ = self.model?.$update.sink(receiveValue: {[weak self] value in self?.onUpdate(value)})
        }

        /// TODO: Fix it and read comments above.
        /// This is intentional update publisher.
        /// It is one-fire event and it is necessary only when view exists.
        /// It doesn't store value.
        self.model?.intentionalUpdatePublisher.sink(receiveValue: { [weak self] (value) in
            self?.onUpdate(value)
        }).store(in: &self.subscriptions)

        // Set Focus
        self.model?.setFocusPublisher.sink(receiveValue: { [weak self] (value) in
            guard let position = value.position else { return }
            self?.textView?.setFocus(position)
        }).store(in: &self.subscriptions)

        // Resign first responder
        self.model?.shouldResignFirstResponderPublisher.sink(receiveValue: { [weak self] (value) in
            _ = self?.textView.resignFirstResponder()
        }).store(in: &self.subscriptions)
    }

    // MARK: UI Elements
    private func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.textView = {
            let view = TextViewWithPlaceholder()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.contentView.addSubview(self.textView)
        self.addSubview(self.contentView)
    }

    // MARK: Layout
    private func addLayout() {
        if let view = self.contentView, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }

        if let view = self.textView, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }

    override var intrinsicContentSize: CGSize {
        .zero
    }

}

// MARK: Updates
private extension BlockTextView {
    func onUpdate(receive update: BlockTextViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value):
            // NOTE: Read these cases carefully.
            // 1. self.textView.textStorage.length == 0.
            // This case is simple. We should take _typingAttributes_ from textView and configure new attributed string.
            // 2. self.textView.textStorage.length != 0.
            // We should _replace_ text in range, however, if we don't check that our string is empty, we will configure incorrect attributes.
            // There is no way to set attributes for text, becasue it is inherited from attributes that are assigned to first character, that will be replaced.
            guard value != self.textView.textStorage.string else {
                /// Skip updating row without
                return
            }
            if self.textView.textStorage.length == 0 {
                let text = NSAttributedString(string: value, attributes: self.textView.typingAttributes)
                self.textView.textStorage.setAttributedString(text)
            }
            else {
                self.textView.textStorage.replaceCharacters(in: .init(location: 0, length: self.textView.textStorage.length), with: value)
            }
        case let .attributedText(value):
            let text = NSMutableAttributedString.init(attributedString: value)

            // TODO: Poem "Do we need to add font?"
            //
            // Actually, don't know. Should think about this problem ( when and where ) we should set font of attributed string.
            //
            // The main problem is that we should use `.font` to apply attributes to `NSAttributedString`.
            //
            // Example code below.
            //
            // let font: UIFont = self.textView.typingAttributes[.foregroundColor] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
            // text.addAttributes([.font : font], range: .init(location: 0, length: text.length))
            guard text != self.textView.textStorage else {
                return
            }
            if self.textView.textStorage.length == 0 {
                self.textView.textStorage.setAttributedString(text)
            }
            else {
                /// Actually, we should add more logic here.
                /// If it is happenning, that means, that some event occurs when user typing or when page is already open.
                /// It may be a blockSetText event from external user.
                /// Lets keep it simple for now.
                self.textView.textStorage.setAttributedString(text)
                // self.textView.textStorage.replaceCharacters(in: .init(location: 0, length: self.textView.textStorage.length), with: value)
            }
        case let .auxiliary(value):
            self.textView.blockColor = value.blockColor
            self.textView.textAlignment = value.textAlignment
        case let .payload(value):
            self.onUpdate(.attributedText(value.attributedString))
            
            /// We changed order, because textAlignment is a part of NSAttributedString.
            /// That means, we have to move processing of textAlignment to MarksStyle.
            /// It is a part of NSAttributedString attributes ( `NSParagraphStyle.alignment` ).
            ///
            self.onUpdate(.auxiliary(value.auxiliary))
        }
    }
    
    func onUpdate(_ update: BlockTextViewModel.Update) {
        /// TODO: Maybe we don't need this dispatching.
        /// Rethink later.
        ///
//        DispatchQueue.main.async {
            self.onUpdate(receive: update)
//        }
    }
}

// MARK: - Configuration

extension BlockTextView {
    func configured(_ options: BlockTextView.Options) -> Self {
        self.options = options
        return self
    }
    
    func configured(_ model: BlockTextViewModel?) -> Self {
        self.subscriptions.removeAll()
        self.model = model
        self.textView.delegate = nil
        self.textView.setupPublishers()

        if let textView = self.textView, let model = self.model {
            textView.coordinator = nil
            _ = model.configured(firstResponderChangePublisher: textView.firstResponderChangePublisher)
            _ = builder.makeUIView(textView, coordinator: model.coordinator)
        }
        self.setupInteractions()

        return self
    }
    
    func configured(placeholder: BlockTextView.Placeholder) -> Self {
        self.update(placeholder: placeholder)
        return self
    }
}

// MARK: - Placeholder

extension BlockTextView {
    struct Placeholder {
        private(set) var text: String?
        private(set) var attributedText: NSAttributedString?
        private(set) var attributes: [NSAttributedString.Key: Any] = [:]
        
        fileprivate var placeholder: NSAttributedString {
            if let result = attributedText {
                return result
            }
            else {
                return NSMutableAttributedString.init(string: self.text ?? "", attributes: attributes)
            }
        }
        
        func configured(text: String?) -> Self {
            .init(text: text, attributedText: self.attributedText, attributes: self.attributes)
        }
        
        func configured(attributedText: NSAttributedString?) -> Self {
            .init(text: self.text, attributedText: attributedText, attributes: self.attributes)
        }
        
        func configured(attributes: [NSAttributedString.Key: Any] = [:]) -> Self {
            .init(text: self.text, attributedText: self.attributedText, attributes: attributes)
        }
    }
}
