import Foundation
import UIKit
import Combine
import os
import BlocksModels


// MARK: - BlockTextView

final class BlockTextView: UIView {
    
    private var subscriptions: Set<AnyCancellable> = []
    weak var delegate: TextViewDelegate?

    var coordinator: BlockTextViewCoordinator? {
        didSet {
            coordinator?.textSizeChangePublisher
                .sink { [weak self] _ in
                    self?.delegate?.sizeChanged()
                }
                .store(in: &subscriptions)

            coordinator?.configureEditingToolbarHandler(textView)
            // Because we set new coordinator we want to use
            // new coordinator's input views instead of old coordinator views
            coordinator?.switchInputs(textView)
            coordinator?.configure(
                textView,
                contextualMenuStream: textView.contextualMenuPublisher
            )
            // When sending signal with send() in textView
            // textStorageEventsSubject subscribers installed
            // in coordinator configured(textStorageStream:)
            // method have not being called, it leads us to
            // deleting text in textView without updating it in block model
            textView.delegate = coordinator
            coordinator?.configureMarksPanePublisher(textView)
        }
    }

    let textView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.autocorrectionType = .no
        return textView
    }()

    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override vars
    
    override var intrinsicContentSize: CGSize {
        .zero
    }

}

// MARK: - BlockTextViewInput

extension BlockTextView: TextViewManagingFocus, TextViewUpdatable {
    
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ focus: TextViewFocus?) {
        guard let position = focus?.position else { return }
        
        textView.setFocus(position)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        coordinator?.focusPosition()
    }

    func apply(update: TextViewUpdate) {
        onUpdate(receive: update)
    }
    
    private func onUpdate(receive update: TextViewUpdate) {
        switch update {
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
            self.onUpdate(receive: .attributedText(value.attributedString))
            
            /// We changed order, because textAlignment is a part of NSAttributedString.
            /// That means, we have to move processing of textAlignment to MarksStyle.
            /// It is a part of NSAttributedString attributes ( `NSParagraphStyle.alignment` ).
            ///
            self.onUpdate(receive: .auxiliary(value.auxiliary))
        }
    }
    
}

// MARK: - Private extension

private extension BlockTextView {
    
    func setupView() {
        addSubview(textView) {
            $0.pinToSuperview()
        }
        
        textView.firstResponderChangePublisher
            .sink { [weak self] change in
                switch change {
                case .become:
                    self?.delegate?.changeFirstResponderState(change)
                case .resign:
                    return
                }
            }
            .store(in: &subscriptions)
    }
    
}
