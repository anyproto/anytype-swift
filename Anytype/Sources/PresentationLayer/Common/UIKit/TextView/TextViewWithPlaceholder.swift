import UIKit

final class TextViewWithPlaceholder: UITextView {
    
    // MARK: - Views
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        return label
    }()

    private let blockLayoutManager = TextBlockLayoutManager()

    private let onFirstResponderChange: (TextViewFirstResponderChange) -> ()

    // MARK: - Internal variables
    
    weak var customTextViewDelegate: TextViewDelegate?

    /// Custom color that applyed after `primaryColor`and `foregroundColor`
    var tertiaryColor: UIColor? {
        didSet {
            blockLayoutManager.tertiaryColor = tertiaryColor
        }
    }

    /// Default font color. Applied as the lowest priority color.
    var defaultFontColor: UIColor? {
        didSet {
            blockLayoutManager.defaultColor = defaultFontColor
        }
    }

    /// Color for selected state
    var selectedColor: UIColor? {
        didSet {
            blockLayoutManager.primaryColor = selectedColor
        }
    }
    
    /// Available markup options (bold, italic, strikethrough, etc)
    var availableTextAttributes = [BlockHandlerActionType.TextAttributesType]() {
        didSet {
            if availableTextAttributes != oldValue {
                setupMenu()
                UIMenuController.shared.update()
            }
        }
    }

    // MARK: - Overrides
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            setupPlaceholderLayout()
        }
    }

    override var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            if let font = super.typingAttributes[.font] as? UIFont {
                placeholderLabel.font = font
            }
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        onFirstResponderChange(.become)
        if value {
            setupMenu()
        }
        return value
    }

    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        onFirstResponderChange(.resign)
        if value {
            UIMenuController.shared.menuItems = nil
        }
        return value
    }

    // MARK: - Initialization
        
    init(
        frame: CGRect,
        textContainer: NSTextContainer?,
        onFirstResponderChange: @escaping (TextViewFirstResponderChange) -> ()
    ) {
        self.onFirstResponderChange = onFirstResponderChange
        
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(blockLayoutManager)
        let container = textContainer ?? NSTextContainer()
        blockLayoutManager.addTextContainer(container)

        super.init(frame: frame, textContainer: container)

        self.setup()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        fatalError("Not implemented")
    }
    

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

// MARK: - Private extension

private extension TextViewWithPlaceholder {
    
    func setup() {
        textStorage.delegate = self
        addSubview(placeholderLabel)
        
        setupPlaceholderLayout()
    }

    func setupPlaceholderLayout() {
        removeConstraints(placeholderLabel.constraints)
        placeholderLabel.layoutUsing.anchors {
            $0.leading.equal(to: leadingAnchor, constant: textContainerInset.left)
            $0.trailing.equal(to: trailingAnchor, constant: -textContainerInset.right)
            $0.top.equal(to: topAnchor, constant: textContainerInset.top)
            $0.bottom.equal(to: bottomAnchor, constant: -textContainerInset.bottom)
            $0.width.equal(to: widthAnchor)
        }
    }
    
    private func syncPlaceholder() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func setupMenu() {
        UIMenuController.shared.menuItems = availableTextAttributes.map { item in
            let selector: Selector = {
                switch item {
                case .bold:
                    return #selector(didSelectContextMenuActionBold)
                case .italic:
                    return #selector(didSelectContextMenuActionItalic)
                case .strikethrough:
                    return #selector(didSelectContextMenuActionStrikethrough)
                case .keyboard:
                    return #selector(didSelectContextMenuActionCode)
                }
            }()
            
            return UIMenuItem(
                title: item.title,
                action: selector
            )
        }
    }
}

// MARK: - Contextual Menu

extension TextViewWithPlaceholder {
    
    @objc private func didSelectContextMenuActionBold() {
        handleMenuAction(.bold)
    }
    
    @objc private func didSelectContextMenuActionItalic() {
        handleMenuAction(.italic)
    }
    
    @objc private func didSelectContextMenuActionStrikethrough() {
        handleMenuAction(.strikethrough)
    }
    
    @objc private func didSelectContextMenuActionCode() {
        handleMenuAction(.keyboard)
    }

    private func handleMenuAction(_ action: BlockHandlerActionType.TextAttributesType) {
        let range = selectedRange

        customTextViewDelegate?.didReceiveAction(
            .changeTextStyle(action, range)
        )
    }
}

// MARK: - NSTextStorageDelegate

extension TextViewWithPlaceholder: NSTextStorageDelegate {
    // We can't use this delegate func to update our block model as we don't know source of changes (middleware or user).
    // If in future we want here change attributes then we should send command to middleware.
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.syncPlaceholder()
    }
}

// MARK: - Placeholder

extension TextViewWithPlaceholder {
    
    func update(placeholder: NSAttributedString?) {
        placeholderLabel.attributedText = placeholder
    }
}

// MARK: - ContextMenuAction

private extension BlockHandlerActionType.TextAttributesType {

    var title: String {
        switch self {
        case .bold:
            return "Bold".localized
        case .italic:
            return "Italic".localized
        case .strikethrough:
            return "Strikethrough".localized
        case .keyboard:
            return "Code".localized
        }
    }
}
