import Combine
import BlocksModels
import UIKit

struct TextBlockContentConfiguration: BlockConfiguration {
    typealias View = TextBlockContentView

    struct Actions {
        let createEmptyBlock: () -> Void
        let showPage: (EditorScreenData) -> Void
        let openURL: (URL) -> Void
        let changeText: (NSAttributedString) -> Void
        let changeTextStyle: (MarkupType, NSRange) -> Void
        let handleKeyboardAction: (CustomTextView.KeyboardAction, NSAttributedString) -> Void
        let becomeFirstResponder: () -> Void
        let resignFirstResponder: () -> Void

        let textBlockSetNeedsLayout: () -> Void

        let textViewWillBeginEditing: (UITextView) -> Void
        let textViewDidBeginEditing: (UITextView) -> Void
        let textViewDidEndEditing: (UITextView) -> Void

        let textViewDidChangeCaretPosition: (NSRange) -> Void
        let textViewDidApplyChangeType: (TextChangeType) -> Void
    }

    let content: BlockText
    let isCheckable: Bool
    let shouldDisplayPlaceholder: Bool
    @EquatableNoop private(set) var focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    let alignment: NSTextAlignment

    @EquatableNoop private(set) var actions: Actions

    init(
        content: BlockText,
        isCheckable: Bool,
        shouldDisplayPlaceholder: Bool,
        focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    ) {
        self.content = content
        self.focusPublisher = focusPublisher
        self.isCheckable = isCheckable
        self.shouldDisplayPlaceholder = shouldDisplayPlaceholder
    }
}
