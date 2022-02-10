import UIKit

extension CustomTextView: UITextViewDelegate {    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard options.createNewBlockOnEnter else { return true }
        guard let delegate = delegate else { return true }
        
        let range = textView.attributedText.rangeWithoutMention(range)
        let keyAction = CustomTextView.KeyboardAction.build(text: textView.attributedText.string, range: range, replacement: text)

        if let keyAction = keyAction {
            guard delegate.keyboardAction(keyAction) else { return false }
        }

        return delegate.shouldChangeText(range: range, replacementText: text)
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
