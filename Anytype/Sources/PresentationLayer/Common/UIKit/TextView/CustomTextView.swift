import Combine
import UIKit
import BlocksModels

final class CustomTextView: UIView {
    
    weak var delegate: TextViewDelegate? {
        didSet {
            textView.customTextViewDelegate = delegate
        }
    }

    var textSize: CGSize?

    private(set) lazy var textView = createTextView()
    private var firstResponderSubscription: AnyCancellable?

    var options: CustomTextViewOptions = .init(createNewBlockOnEnter: false, autocorrect: false)
    var accessoryViewSwitcher: AccessoryViewSwitcher?
    
    init() {
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .zero
    }
    
    func setupView() {
        textView.delegate = self

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }

    func setCustomTextViewOptions(options: CustomTextViewOptions) {
        self.options = options
    }

    func setAccessoryViewSwitcher(accessoryViewSwitcher: AccessoryViewSwitcher) {
        self.accessoryViewSwitcher = accessoryViewSwitcher
    }
}

// MARK: - BlockTextViewInput

extension CustomTextView: TextViewManagingFocus {
    
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ focus: BlockFocusPosition?) {
        guard let focus = focus else { return }
        
        textView.setFocus(focus)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard textView.isFirstResponder else { return nil }
        let caretLocation = textView.selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(textView.selectedRange)
    }
}

// MARK: - Views

private extension CustomTextView {
    func createTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(frame: .zero, textContainer: nil) { [weak self] change in
            self?.delegate?.changeFirstResponderState(change)
        }
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.linkTextAttributes = [:]
        textView.autocorrectionType = options.autocorrect ? .yes : .no
        return textView
    }
}
