import UIKit
import Foundation
import UniformTypeIdentifiers
import AnytypeCore
import Services

final class TextViewWithPlaceholder: UITextView {
    private enum InsetEdgeType {
        case top
        case bottom
        case left
        case right
    }
    
    override var undoManager: UndoManager? { nil }
    
    // MARK: - Views
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        return label
    }()
    
    private var placeholderConstraints: [InsetEdgeType: NSLayoutConstraint] = [:]
    private var blockLayoutManager = TextBlockLayoutManager() {
        didSet {
            blockLayoutManager.allowsNonContiguousLayout = true
        }
    }
    var isLockedForEditing = false
    
    // MARK: - Internal variables
    
    weak var customTextViewDelegate: (any CustomTextViewDelegate)?
    
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
    
    // MARK: - Overrides
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderLayout()
        }
    }
    
    override var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            if let font = super.typingAttributes[.font] as? UIFont {
                placeholderLabel.font = font
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        let canBecome = super.canBecomeFirstResponder
        return isLockedForEditing ? false : canBecome
    }
    
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        
        reloadGestures()
        return value
    }
    //
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Force showing paste menu item in text view for other type than text
        if action == #selector(TextViewWithPlaceholder.paste(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    //
    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        
        reloadGestures()
        return value
    }
    
    override func paste(_ sender: Any?) {
        guard let customTextViewDelegate else {
            return super.paste(sender)
        }
        
        if customTextViewDelegate.shouldPaste(range: selectedRange) {
            super.paste(sender)
        }
    }
    
    override func copy(_ sender: Any?) {
        guard let customTextViewDelegate else {
            return super.copy(sender)
        }
        
        customTextViewDelegate.copy(range: selectedRange)
    }
    
    override func cut(_ sender: Any?) {
        guard let customTextViewDelegate else {
            return super.copy(sender)
        }
        
        customTextViewDelegate.cut(range: selectedRange)
    }
    
    // MARK: - Initialization
    override init(
        frame: CGRect,
        textContainer: NSTextContainer?
    ) {
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(blockLayoutManager)
        let container = textContainer ?? NSTextContainer()
        blockLayoutManager.addTextContainer(container)
        
        super.init(frame: frame, textContainer: container)
        
        self.setup()
    }
    
    @available(*, unavailable)
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
        
        placeholderLabel.layoutUsing.anchors {
            placeholderConstraints[.left] = $0.leading.equal(to: leadingAnchor, constant: textContainerInset.left)
            placeholderConstraints[.right] = $0.trailing.equal(to: trailingAnchor, constant: -textContainerInset.right)
            placeholderConstraints[.top] = $0.top.equal(to: topAnchor, constant: textContainerInset.top)
            placeholderConstraints[.bottom] = $0.bottom.equal(to: bottomAnchor, constant: -textContainerInset.bottom)
            $0.width.equal(to: widthAnchor).priority = .defaultHigh - 1
        }
        placeholderLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }
    
    func updatePlaceholderLayout() {
        placeholderConstraints[.left]?.constant = textContainerInset.left
        placeholderConstraints[.right]?.constant = textContainerInset.right
        placeholderConstraints[.top]?.constant = textContainerInset.top
        placeholderConstraints[.bottom]?.constant = textContainerInset.bottom
    }
    
    
    
    private func syncPlaceholder() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
}

// MARK: - NSTextStorageDelegate

extension TextViewWithPlaceholder: NSTextStorageDelegate {
    // We can't use this delegate func to update our block model as we don't know source of changes (middleware or user).
    // If in future we want here change attributes then we should send command to middleware.
    nonisolated func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        Task { @MainActor in
            syncPlaceholder()
        }
    }
}

extension TextViewWithPlaceholder {
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            gestureRecognizer.isEnabled = isFirstResponder
        }
        return super.addGestureRecognizer(gestureRecognizer)
    }
    
    func reloadGestures() {
        gestureRecognizers?.forEach {
            if $0.isKind(of: UILongPressGestureRecognizer.self) {
                $0.isEnabled = isFirstResponder
            }
        }
    }
    
}
// MARK: - Placeholder

extension TextViewWithPlaceholder {
    
    func update(placeholder: NSAttributedString?) {
        placeholderLabel.attributedText = placeholder
    }
}

