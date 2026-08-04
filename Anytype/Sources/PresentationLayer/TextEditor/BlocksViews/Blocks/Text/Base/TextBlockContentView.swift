import UIKit
import Combine
import Services
import AnytypeCore


final class TextBlockContentView: UIView, BlockContentView, DynamicHeightView, FirstResponder {
    var isFirstResponderValueChangeHandler: ((Bool) -> Void)?
    
    // MARK: - DynamicHeightView
    var heightDidChanged: (() -> Void)?
    
    // MARK: - Views
    private let contentView = UIView()
    private let textContainerView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        self?.actions?.createEmptyBlock()
    }
    private lazy var textBlockLeadingView = TextBlockLeadingView()
    
    private let mainStackView: UIStackView = makeMainStackView()
    
    private var topContentConstraint: NSLayoutConstraint?
    private var bottomContentnConstraint: NSLayoutConstraint?
    private var contentSpacingConstraint: NSLayoutConstraint?
    private var focusSubscription: AnyCancellable?
    private var resetSubscription: AnyCancellable?
    
    private(set) var actions: TextBlockContentConfiguration.Actions?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupLayout()
    }
    
    func update(with configuration: TextBlockContentConfiguration) {
        actions = configuration.actions
        applyNewConfiguration(configuration: configuration)
    }
    
    func update(with state: UICellConfigurationState) {
        textView.textView.isLockedForEditing = state.isLocked
        createEmptyBlockButton.isEnabled = !state.isLocked
        textBlockLeadingView.checkboxView?.isUserInteractionEnabled = !state.isLocked
        textBlockLeadingView.calloutIconView?.isUserInteractionEnabled = !state.isLocked
        textView.textView.isUserInteractionEnabled = state.isEditing
    }
    
    // MARK: - Setup views
    
    private func setupLayout() {
        textContainerView.addSubview(textBlockLeadingView) {
            $0.pinToSuperview(excluding: [.right])
        }
        textContainerView.addSubview(textView) {
            $0.pinToSuperview(excluding: [.left])
            // For textBlockLeadingView is visible
            contentSpacingConstraint = $0.leading.equal(to: textBlockLeadingView.trailingAnchor, priority: .required)
            // For textBlockLeadingView is hidden
            $0.leading.equal(to: textContainerView.leadingAnchor, priority: .defaultHigh)
        }
            
        contentView.addSubview(textContainerView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.greaterThanOrEqual(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }
        
        createEmptyBlockButton.layoutUsing.anchors {
            $0.height.equal(to: 26)
        }
        
        mainStackView.addArrangedSubview(contentView)
        contentView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        
        mainStackView.addArrangedSubview(createEmptyBlockButton)
        
        addSubview(mainStackView) {
            $0.pinToSuperview()
        }
    }
    
    // MARK: - Apply configuration
    
    /// Synchronous first-responder grab for the Enter-created row focus handoff. Runs right
    /// after the apply that inserted this cell — outside the dequeue pass, where a synchronous
    /// becomeFirstResponder is unsafe (see applyNewConfiguration).
    func takeFocus(at position: BlockFocusPosition) {
        textView.textView.setFocus(position)
    }

    private func applyNewConfiguration(configuration: TextBlockContentConfiguration) {
        applyTextStorage(configuration.attributedString)

        textBlockLeadingView.update(blockId: configuration.blockId, style: TextBlockLeadingStyle(with: configuration))
    
        let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
        TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)
        
        updateAllConstraint(configuration: configuration)
        textView.delegate = self
        
        let contentType = configuration.content.contentType
        let isToggleType = contentType == .toggle || contentType.isToggleHeader
        let displayPlaceholder = isToggleType && configuration.shouldDisplayPlaceholder
        UIView.performWithoutAnimation {
            createEmptyBlockButton.isHidden = !displayPlaceholder
            mainStackView.setNeedsLayout()
        }
        
        focusSubscription = configuration
            .focusPublisher
            .receiveOnMain()
            .sink { [weak self] focus in
                self?.textView.textView.setFocus(focus)
            }
        
        resetSubscription = configuration.resetPublisher.sink { [weak self] configuration in
            configuration.map {
                self?.applyNewConfiguration(configuration: $0)
            }
        }
        
        if let position = configuration.initialBlockFocusPosition {
            // Defer: applyNewConfiguration runs during cell dequeue; synchronous becomeFirstResponder triggers delegate side effects that crash on iOS 26.
            DispatchQueue.main.async { [weak self] in
                self?.textView.textView.setFocus(position)
            }
        }
    }

    /// Applies `incoming` to the text storage without needlessly rebuilding the keyboard's
    /// input session. Reconfiguring the cell being typed in (the fork-time identity-rebind
    /// refresh, a remote echo of the local text) with `setAttributedString` resets
    /// autocorrect's word buffer even when nothing changed, so:
    /// - identical characters, identical attributes: no write at all;
    /// - identical characters, different attributes: attributes are applied in place — an
    ///   attribute edit does not touch the word buffer. Characters are compared by `string`,
    ///   not `isEqual(to:)`: UIKit decorates live text with private attributes (e.g.
    ///   NSOriginalFont on font substitution), and a spuriously unequal comparison would
    ///   silently reinstate the session reset;
    /// - different characters: full write — except during an IME composition when `incoming`
    ///   is a stale prefix of the live text (the view is legitimately ahead by the uncommitted
    ///   marked text; the commit syncs view → model, so nothing is lost by skipping). A
    ///   genuinely different non-empty text (undo, a remote edit) still takes the write:
    ///   losing the composition is the lesser damage.
    private func applyTextStorage(_ incoming: NSAttributedString) {
        let liveTextView = textView.textView
        guard liveTextView.isFirstResponder else {
            liveTextView.textStorage.setAttributedString(incoming)
            return
        }
        let liveText: NSAttributedString = liveTextView.attributedText ?? NSAttributedString()
        if liveTextView.markedTextRange != nil {
            guard incoming.string.isNotEmpty, liveText.string.hasPrefix(incoming.string) else {
                setAttributedTextKeepingCaret(incoming, in: liveTextView)
                return
            }
            return
        }
        guard liveText.string == incoming.string else {
            setAttributedTextKeepingCaret(incoming, in: liveTextView)
            return
        }
        guard !liveText.isEqual(to: incoming) else { return }
        let storage = liveTextView.textStorage
        storage.beginEditing()
        incoming.enumerateAttributes(in: NSRange(location: 0, length: incoming.length), options: []) { attributes, range, _ in
            storage.setAttributes(attributes, range: range)
        }
        storage.endEditing()
    }

    /// Replacing the whole storage collapses the selection to the start of the block. While the
    /// view is first responder that reads as the caret jumping to the beginning — a paste is
    /// the common case: its response places the caret after the pasted text, then the middleware
    /// echo reconfigures the cell and the write drops it. Reinstating the offset (clamped to the
    /// new text) keeps the caret where the edit that caused the write left it.
    private func setAttributedTextKeepingCaret(_ incoming: NSAttributedString, in textView: UITextView) {
        let caret = textView.selectedRange
        textView.textStorage.setAttributedString(incoming)
        let location = min(caret.location, incoming.length)
        let length = min(caret.length, incoming.length - location)
        textView.selectedRange = NSRange(location: location, length: length)
    }

    private func updateAllConstraint(configuration: TextBlockContentConfiguration) {
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: configuration.content.contentType)
        
        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = -contentInset.bottom
        
        if textBlockLeadingView.isHidden {
            contentSpacingConstraint?.constant = 0
        } else if configuration.content.contentType == .title, configuration.isCheckable {
            contentSpacingConstraint?.constant = 8
        } else {
            contentSpacingConstraint?.constant = 4
        }
    }
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        return mainStackView
    }
}
