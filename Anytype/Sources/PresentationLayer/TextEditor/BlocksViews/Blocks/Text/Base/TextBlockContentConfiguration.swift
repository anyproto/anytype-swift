import Combine
import Services
import UIKit

struct TextBlockContentConfiguration: BlockConfiguration {
    typealias View = TextBlockContentView
    
    struct Actions {
        let shouldPaste: (NSRange, UITextView) -> Bool
        let copy: (NSRange) -> Void
        let cut: (NSRange) -> Void
        let createEmptyBlock: () -> Void
        let showObject: (String) -> Void
        let openURL: (URL) -> Void
        
        let handleKeyboardAction: (CustomTextView.KeyboardAction, UITextView) -> Void
        let becomeFirstResponder: () -> Void
        let resignFirstResponder: () -> Void
        
        let textBlockSetNeedsLayout: @MainActor (UITextView) -> Void
        
        let textViewDidChangeText: @MainActor (UITextView) -> Void
        
        let textViewWillBeginEditing: @MainActor (UITextView) -> Void
        let textViewDidBeginEditing: @MainActor (UITextView) -> Void
        let textViewDidEndEditing: @MainActor (UITextView) -> Void
        
        let textViewDidChangeCaretPosition: @MainActor (UITextView, NSRange) -> Void
        let textViewShouldReplaceText: @MainActor (UITextView, String, NSRange) -> Bool
        
        let toggleCheckBox: () -> Void
        let toggleDropDown: () -> Void
        let tapOnCalloutIcon: () -> Void
    }
    
    var blockId: String
    var content: BlockText
    var attributedString: NSAttributedString
    var isCheckable: Bool
    var isToggled: Bool
    var isChecked: Bool
    var shouldDisplayPlaceholder: Bool
    var initialBlockFocusPosition: BlockFocusPosition?
    var alignment: NSTextAlignment
    @EquatableNoop var textContainerInsets: UIEdgeInsets
    @EquatableNoop var placeholderAttributes: [NSAttributedString.Key: Any]
    @EquatableNoop var typingAttributes: (Int) -> [NSAttributedString.Key: Any]
    @EquatableNoop private(set) var focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    @EquatableNoop private(set) var resetPublisher: AnyPublisher<TextBlockContentConfiguration?, Never>
    @EquatableNoop private(set) var actions: Actions
    
    init(
        blockId: String,
        content: BlockText,
        attributedString: NSAttributedString,
        placeholderAttributes: [NSAttributedString.Key: Any],
        typingAttributes: @escaping (Int) -> [NSAttributedString.Key: Any],
        textContainerInsets: UIEdgeInsets,
        alignment: NSTextAlignment,
        isCheckable: Bool,
        isToggled: Bool,
        isChecked: Bool,
        shouldDisplayPlaceholder: Bool,
        initialBlockFocusPosition: BlockFocusPosition?,
        focusPublisher: AnyPublisher<BlockFocusPosition, Never>,
        resetPublisher: AnyPublisher<TextBlockContentConfiguration?, Never>,
        actions: Actions
    ) {
        self.blockId = blockId
        self.content = content
        self.attributedString = attributedString
        self.placeholderAttributes = placeholderAttributes
        self.typingAttributes = typingAttributes
        self.textContainerInsets = textContainerInsets
        self.alignment = alignment
        self.isCheckable = isCheckable
        self.isToggled = isToggled
        self.isChecked = isChecked
        self.shouldDisplayPlaceholder = shouldDisplayPlaceholder
        self.initialBlockFocusPosition = initialBlockFocusPosition
        self.focusPublisher = focusPublisher
        self.resetPublisher = resetPublisher
        
        self.actions = actions
    }
}

extension TextBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        switch content.contentType {
        case .title:
            return .init(top: 0, left: 20, bottom: 0, right: 20)
        case .description:
            return .init(top: 8, left: 20, bottom: 0, right: 20)
        case .header:
            return .init(top: 24, left: 20, bottom: 2, right: 20)
        case .header2, .header3:
            return .init(top: 16, left: 20, bottom: 2, right: 20)
        default:
            return .init(top: 0, left: 20, bottom: 2, right: 20)
        }
    }
}

extension TextBlockContentConfiguration {
    @MainActor
    static let empty = TextBlockContentConfiguration(
        blockId: UUID().uuidString,
        content: .empty(contentType: .text),
        attributedString: NSAttributedString(),
        placeholderAttributes: [:],
        typingAttributes: { _ in [:] },
        textContainerInsets: .zero,
        alignment: .left,
        isCheckable: false,
        isToggled: false,
        isChecked: false,
        shouldDisplayPlaceholder: false,
        initialBlockFocusPosition: nil,
        focusPublisher: .empty(),
        resetPublisher: .empty(),
        actions: .init(
            shouldPaste: { _, _ in false },
            copy: { _ in },
            cut: { _ in },
            createEmptyBlock: { },
            showObject: { _ in },
            openURL: { _ in },
            handleKeyboardAction: { _, _ in },
            becomeFirstResponder: { },
            resignFirstResponder: { },
            textBlockSetNeedsLayout: { _ in },
            textViewDidChangeText: { _ in},
            textViewWillBeginEditing: { _ in},
            textViewDidBeginEditing: { _ in},
            textViewDidEndEditing: { _ in },
            textViewDidChangeCaretPosition: { _, _ in},
            textViewShouldReplaceText: { _, _, _ in false },
            toggleCheckBox: { },
            toggleDropDown: { },
            tapOnCalloutIcon: { }
        )
    )
}
