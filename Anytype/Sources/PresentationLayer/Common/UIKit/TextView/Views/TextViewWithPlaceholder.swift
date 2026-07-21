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

    // Where the selection is pinned while the user shift+arrows: UITextView exposes only the
    // NSRange, so without the anchor a shift+Down that natively shrinks an upward selection is
    // indistinguishable from one that has nothing left to extend and should escalate.
    private var selectionAnchorLocation: Int?
    private var previousSelectedRange: NSRange?
    private let selectionProbe = UIPanGestureRecognizer()
    private let handleSniffer = SelectionHandleSniffer()
    
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

    // Arrow keys are "system behavior" inside a text view — the text input system consumes
    // them before press events, so interception must happen at the key-command layer. UIKit
    // queries this property per key press; the commands are offered only when the selection
    // has nothing left to extend inside this block.
    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []
        if canEscalateSelection(down: true) {
            commands.append(escalationCommand(input: UIKeyCommand.inputDownArrow))
        }
        if canEscalateSelection(down: false) {
            commands.append(escalationCommand(input: UIKeyCommand.inputUpArrow))
        }
        return commands
    }

    private func escalationCommand(input: String) -> UIKeyCommand {
        let command = UIKeyCommand(input: input, modifierFlags: .shift, action: #selector(escalateSelectionBeyondBoundary))
        command.wantsPriorityOverSystemBehavior = true
        return command
    }

    @objc private func escalateSelectionBeyondBoundary() {
        customTextViewDelegate?.escalateToBlockSelection()
    }

    private func canEscalateSelection(down: Bool) -> Bool {
        let selection = selectedRange
        if down {
            guard selection.location + selection.length == textStorage.length else { return false }
            return selection.length == 0 || selectionAnchorLocation == selection.location
        } else {
            guard selection.location == 0 else { return false }
            return selection.length == 0 || selectionAnchorLocation == selection.location + selection.length
        }
    }

    func trackSelectionAnchor() {
        let new = selectedRange
        let old = previousSelectedRange
        previousSelectedRange = new
        if new.length == 0 {
            selectionAnchorLocation = new.location
        } else if let old, old.location == new.location {
            selectionAnchorLocation = new.location
        } else if let old, old.location + old.length == new.location + new.length {
            selectionAnchorLocation = new.location + new.length
        } else {
            // A fresh selection (double-tap word, programmatic set) has no history; treating the
            // start as the anchor matches how a subsequent shift+Down extends it natively.
            selectionAnchorLocation = new.location
        }
    }

    // MARK: - Selection handle escalation

    /// The system's selection-handle drags never reach recognizers added to the editor view
    /// hierarchy, but UIKit does consult a probe recognizer attached to the text view about
    /// simultaneous recognition — handing over a live reference to the private range-adjustment
    /// recognizer, which public `addTarget` can then observe. (Runestone/Steve Shepard pattern.)
    var onSelectionHandlePan: ((UIPanGestureRecognizer) -> Void)?

    private func setupSelectionHandleSniffer() {
        handleSniffer.textView = self
        selectionProbe.cancelsTouchesInView = false
        selectionProbe.delaysTouchesBegan = false
        selectionProbe.delegate = handleSniffer
        addGestureRecognizer(selectionProbe)
    }

    fileprivate func handleSelectionHandlePan(_ recognizer: UIPanGestureRecognizer) {
        onSelectionHandlePan?(recognizer)
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
        setupSelectionHandleSniffer()
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

// The scroll view is the delegate of its own internal recognizers, so this must not be
// implemented on the text view itself. For every touch the probe participates in, UIKit asks
// about each peer recognizer — including private system ones — and that callback is the only
// public place a reference to the selection-handle drag recognizer can be obtained.
@MainActor
private final class SelectionHandleSniffer: NSObject, UIGestureRecognizerDelegate {
    weak var textView: TextViewWithPlaceholder?
    private let observedRecognizers = NSHashTable<UIGestureRecognizer>.weakObjects()

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        sniff(otherGestureRecognizer)
        return true
    }

    private func sniff(_ recognizer: UIGestureRecognizer) {
        guard textView != nil, !observedRecognizers.contains(recognizer) else { return }
        let className = String(describing: type(of: recognizer))
        let rangeAdjustmentClass = NSClassFromString("UITextRangeAdjustmentGestureRecognizer")
        let matchesClass = rangeAdjustmentClass.map { recognizer.isKind(of: $0) } ?? false
        guard matchesClass || className.contains("RangeAdjustment") else { return }
        // The target must not be the text view: the system recognizer is attached to that same
        // text view and addTarget retains its target, which would close a retain cycle
        // (textView → recognizer → textView). The sniffer only holds the text view weakly.
        recognizer.addTarget(self, action: #selector(handleObservedRecognizer(_:)))
        observedRecognizers.add(recognizer)
    }

    @objc private func handleObservedRecognizer(_ recognizer: UIPanGestureRecognizer) {
        textView?.handleSelectionHandlePan(recognizer)
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
        // Visibility must be resynced synchronously here: cell (re)configuration sets the text
        // programmatically before this call, and the didProcessEditing-driven sync below is a
        // deferred task — a reused cell that last showed a placeholder would otherwise render
        // it under the new non-empty text until that task wins the race.
        syncPlaceholder()
    }
}

