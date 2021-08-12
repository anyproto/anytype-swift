import UIKit


extension CustomTextView: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard options.createNewBlockOnEnter else { return true }
        
        accessoryViewSwitcher?.textViewChange = textView.textChangeType(changeTextRange: range, replacementText: text)

        let keyAction = CustomTextView.UserAction.KeyboardAction.convert(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        )
        if let keyAction = keyAction {
            if case let .enterInsideContent(currentText, _) = keyAction {
                self.textView.text = currentText
            }
            return delegate?.didReceiveAction(
                CustomTextView.UserAction.keyboardAction(keyAction)
            ) ?? true
        }

        return delegate?.didReceiveAction(
            .shouldChangeText(
                range: range,
                replacementText: text,
                mentionsHolder: textView
            )
        ) ?? true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        accessoryViewSwitcher?.switchInputs(textView: textView)

        if textView.isFirstResponder {
            delegate?.didReceiveAction(
                .changeCaretPosition(textView.selectedRange)
            )
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.inputAccessoryView.isNil {
            textView.inputAccessoryView = accessoryViewSwitcher?.accessoryView
        }
        accessoryViewSwitcher?.switchInputs(textView: textView)
        delegate?.willBeginEditing()

        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textSize = textView.intrinsicContentSize
        delegate?.didBeginEditing()
    }

    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.intrinsicContentSize

        accessoryViewSwitcher?.switchInputs(textView: textView)
        delegate?.didChangeText(textView: textView)
        if !(accessoryViewSwitcher?.textTypingIsUsingForAccessoryViewContentFiltering() ?? false) {
            // We type only text to filter content inside accessory view
            delegate?.didReceiveAction(
                .changeText(textView.attributedText)
            )
        }

        guard textSize?.height != contentSize.height else { return }
        textSize = contentSize
        delegate?.sizeChanged()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        accessoryViewSwitcher?.textViewChange = nil
    }
}
