import UIKit

// MARK: - TextView

final class TextViewWithPlaceholder: UITextView {

    weak var userInteractionDelegate: TextViewUserInteractionProtocol?

    
    // MARK: - Views
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let blockLayoutManager = TextBlockLayoutManager()
    private var placeholderConstraints = [NSLayoutConstraint]()

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
            self.updatePlaceholderLayout()
        }
    }

    override var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            if let font = super.typingAttributes[.font] as? UIFont {
                self.placeholderLabel.font = font
            }
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
    
    private let onFirstResponderChange: (TextViewFirstResponderChange) -> ()
    
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
        setupUIElements()
        updatePlaceholderLayout()
    }

    func setupUIElements() {
        self.textStorage.delegate = self
        self.addSubview(self.placeholderLabel)
    }

    func updatePlaceholderLayout() {
        let view = self.placeholderLabel
        if let superview = view.superview {
            let insets = self.textContainerInset
            let lineFragmentPadding = self.textContainer.lineFragmentPadding

            if !self.placeholderConstraints.isEmpty {
                self.removeConstraints(self.placeholderConstraints)
            }

            self.placeholderConstraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left + lineFragmentPadding),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -(insets.right + lineFragmentPadding)),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
            ]

            NSLayoutConstraint.activate(self.placeholderConstraints)
        }
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

        userInteractionDelegate?.didReceiveAction(
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
    
    private func syncPlaceholder() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func update(placeholder: NSAttributedString?) {
        self.placeholderLabel.attributedText = placeholder
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
