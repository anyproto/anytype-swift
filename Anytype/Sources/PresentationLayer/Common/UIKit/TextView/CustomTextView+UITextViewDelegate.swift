import UIKit


extension CustomTextView: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard options.createNewBlockOnEnter else { return true }
        
        inputSwitcher.textViewChange = textView.textChangeType(changeTextRange: range, replacementText: text)

        let keyAction = CustomTextView.UserAction.KeyboardAction.convert(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        )
        if let keyAction = keyAction {
            if case let .enterInsideContent(currentText, _) = keyAction {
                self.textView.text = currentText
            }
            return userInteractionDelegate?.didReceiveAction(
                CustomTextView.UserAction.keyboardAction(keyAction)
            ) ?? true
        }

        return userInteractionDelegate?.didReceiveAction(
            .shouldChangeText(
                range: range,
                replacementText: text,
                mentionsHolder: textView
            )
        ) ?? true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        inputSwitcher.switchInputs(customTextView: self)

        if textView.isFirstResponder {
            userInteractionDelegate?.didReceiveAction(
                .changeCaretPosition(textView.selectedRange)
            )
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.inputAccessoryView.isNil {
            textView.inputAccessoryView = accessoryView
        }
        inputSwitcher.switchInputs(customTextView: self)
        delegate?.willBeginEditing()

        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textSize = textView.intrinsicContentSize
        delegate?.didBeginEditing()
    }

    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.intrinsicContentSize

        inputSwitcher.switchInputs(customTextView: self)
        delegate?.didChangeText(textView: textView)
        if !inputSwitcher.textTypingIsUsingForAccessoryViewContentFiltering() {
            // We type only text to filter content inside accessory view
            userInteractionDelegate?.didReceiveAction(
                .changeText(textView.attributedText)
            )
        }

        guard textSize?.height != contentSize.height else { return }
        textSize = contentSize
        delegate?.sizeChanged()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        inputSwitcher.textViewChange = nil
    }
}
