import Services
import UIKit
import FloatingPanel
import AnytypeCore

enum MarkdownChange {
    case turnInto(BlockText.Style, text: NSAttributedString)
    case addBlock(type: BlockContentType, text: NSAttributedString)
    case addStyle(MarkupType, text: NSAttributedString, range: NSRange, focusRange: NSRange)
}

protocol MarkdownListener {
    func markdownChange(textView: UITextView, replacementText: String, range: NSRange) -> MarkdownChange?
}

final class MarkdownListenerImpl: MarkdownListener {
    
    private let internalListeners: [MarkdownListener]
    
    init(internalListeners: [MarkdownListener]) {
        self.internalListeners = internalListeners
    }
    
    // MARK: - MarkdownListener
    
    func markdownChange(textView: UITextView, replacementText: String, range: NSRange) -> MarkdownChange? {
        guard textView.textChangeType(changeTextRange: range, replacementText: replacementText) == .typingSymbols else {
            return nil
        }
        
        for listener in internalListeners {
            if let result = listener.markdownChange(textView: textView, replacementText: replacementText, range: range) {
                return result
            }
        }
        
        return nil
    }
}
