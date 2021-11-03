import UIKit

extension CustomTextView: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard options.createNewBlockOnEnter else { return true }
        guard let delegate = delegate else { return true }
        
        let keyAction = CustomTextView.KeyboardAction.build(textView: textView, range: range, replacement: text)

        if let keyAction = keyAction {
            if case let .enterInsideContent(currentText, _) = keyAction {
                self.textView.text = currentText
            }
            guard delegate.keyboardAction(keyAction) else { return false }
        }

        return delegate.shouldChangeText(
            range: range,
            replacementText: text,
            mentionsHolder: textView
        )
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
        delegate?.didReceiveAction(.changeText(textView.attributedText))
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
