import UIKit

extension CustomTextView: UITextViewDelegate {    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let delegate = delegate else { return true }
        
        let range = textView.attributedText.rangeWithoutMention(range)
        let keyAction = CustomTextView.KeyboardAction
            .build(attributedText: textView.attributedText, range: range, replacement: text)

        if let keyAction = keyAction {
            delegate.keyboardAction(keyAction)
            return false
        } else {
            return delegate.shouldChangeText(range: range, replacementText: text)
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.isFirstResponder {
            delegate?.changeCaretPosition(textView.selectedRange)
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.willBeginEditing()
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.didBeginEditing()
    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChangeText(textView)
    }
    
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if !textView.isFirstResponder && interaction == .invokeDefaultAction {
            delegate?.openURL(URL)
        }
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didEndEditing()
    }
}
