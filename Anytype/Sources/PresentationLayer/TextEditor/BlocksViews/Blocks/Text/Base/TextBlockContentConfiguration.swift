import Combine
import BlocksModels
import UIKit

struct TextBlockContentConfiguration: BlockConfiguration {
    typealias View = TextBlockContentView

    struct Actions {
        let createEmptyBlock: () -> Void
        let showPage: (EditorScreenData) -> Void
        let openURL: (URL) -> Void

        let changeTextStyle: (MarkupType, NSRange) -> Void
        let handleKeyboardAction: (CustomTextView.KeyboardAction, NSAttributedString) -> Void
        let becomeFirstResponder: () -> Void
        let resignFirstResponder: () -> Void

        let textBlockSetNeedsLayout: () -> Void

        let textViewDidChangeText: (UITextView) -> Void

        let textViewWillBeginEditing: (UITextView) -> Void
        let textViewDidBeginEditing: (UITextView) -> Void
        let textViewDidEndEditing: (UITextView) -> Void

        let textViewDidChangeCaretPosition: (NSRange) -> Void
        let textViewDidApplyChangeType: (TextChangeType) -> Void

        let toggleCheckBox: () -> Void
        let toggleDropDown: () -> Void
    }

    let blockId: BlockId
    let content: BlockText
    let backgroundColor: UIColor?
    let isCheckable: Bool
    let isToggled: Bool
    let isChecked: Bool
    let shouldDisplayPlaceholder: Bool
    @EquatableNoop private(set) var focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    let alignment: NSTextAlignment

    @EquatableNoop private(set) var actions: Actions

    init(
        blockId: BlockId,
        content: BlockText,
        alignment: NSTextAlignment,
        backgroundColor: UIColor?,
        isCheckable: Bool,
        isToggled: Bool,
        isChecked: Bool,
        shouldDisplayPlaceholder: Bool,
        focusPublisher: AnyPublisher<BlockFocusPosition, Never>,
        actions: Actions
    ) {
        self.blockId = blockId
        self.content = content
        self.alignment = alignment
        self.backgroundColor = backgroundColor
        self.isCheckable = isCheckable
        self.isToggled = isToggled
        self.isChecked = isChecked
        self.shouldDisplayPlaceholder = shouldDisplayPlaceholder
        self.focusPublisher = focusPublisher
        self.actions = actions
    }
}
