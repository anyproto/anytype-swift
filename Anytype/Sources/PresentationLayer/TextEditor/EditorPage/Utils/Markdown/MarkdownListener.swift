import BlocksModels
import UIKit
import FloatingPanel
import AnytypeCore

enum MarkdownChange {
    case turnInto(BlockText.Style, text: NSAttributedString)
    case setText(text: NSAttributedString, caretPosition: NSRange)
}

protocol MarkdownListener {
    func markdownChange(textView: UITextView, replacementText: String, range: NSRange) -> MarkdownChange?
}

final class MarkdownListenerImpl: MarkdownListener {
    private let markupChanger: BlockMarkupChangerProtocol
    
    init(markupChanger: BlockMarkupChangerProtocol) {
        self.markupChanger = markupChanger
    }
    
    func markdownChange(textView: UITextView, replacementText: String, range: NSRange) -> MarkdownChange? {
        guard textView.textChangeType(changeTextRange: range, replacementText: replacementText) == .typingSymbols else {
            return nil
        }
        
        return applyBeginningOfTextShortcuts(textView: textView, replacementText: replacementText, range: range)
    }

    // MARK: - BeginningOfText
    private func applyBeginningOfTextShortcuts(
        textView: UITextView,
        replacementText: String,
        range: NSRange
    ) -> MarkdownChange? {
        var markdown: MarkdownChange?
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                if beginingOfTextHaveShortcutAndCarretInsideIt(
                    text,
                    textView: textView,
                    replacementText: replacementText,
                    range: range
                ) {
                    markdown = applyStyle(
                        shortcut.style,
                        string: textView.attributedText,
                        shortcutLength: text.count - replacementText.count
                    )
                }
            }
        }

        return markdown
    }
    
    private func beginingOfTextHaveShortcutAndCarretInsideIt(
        _ shortcut: String,
        textView: UITextView,
        replacementText: String,
        range: NSRange
    ) -> Bool {
        guard let offsetToCaretPosition = textView.offsetToCaretPosition() else {
            anytypeAssertionFailure("No caret position for markdown call", domain: .markdownListener)
            return false
        }
        guard let replacedText = (textView.text as NSString?)?.replacingCharacters(in: range, with: replacementText) else {
            return false
        }
        
        return replacedText.hasPrefix(shortcut) && shortcut.count >= offsetToCaretPosition
    }

    
    private func applyStyle(_ style: BlockText.Style, string: NSAttributedString, shortcutLength: Int) -> MarkdownChange {
        let text = string.mutable
        text.mutableString .deleteCharacters(in: NSMakeRange(0, shortcutLength))

        return .turnInto(style, text: text)
    }
}
