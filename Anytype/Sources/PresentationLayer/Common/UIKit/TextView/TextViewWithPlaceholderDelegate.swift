import UIKit


extension CustomTextView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard options.createNewBlockOnEnter else { return true }

        // In the case of frequent pressing of enter
        // we can send multiple split requests to middle
        // from the same block, it will leads to wrong order of blocks in array,
        // adding a delay in UITextView makes impossible to press enter very often
        inputSwitcher.textViewChange = textView.textChangeType(changeTextRange: range, replacementText: text)

        // TODO: Using for split block. We should ask delegate what to do
        if text == "\n" && !pressingEnterTimeChecker.exceedsTimeInterval() {
            return false
        }

        CustomTextView.UserAction.KeyboardAction.convert(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        ).flatMap { action in
            if case let .enterInsideContent(currentText, _) = action {
                self.textView.text = currentText
            }
            userInteractionDelegate?.didReceiveAction(
                CustomTextView.UserAction.keyboardAction(action)
            )
        }

        // TODO: Using for split block. We should ask delegate what to do
        if text == "\n" {
            return false
        }

        userInteractionDelegate?.didReceiveAction(
            .shouldChangeText(
                range: range,
                replacementText: text,
                mentionsHolder: textView
            )
        )
        return true
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
            textView.inputAccessoryView = self.editingToolbarAccessoryView
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

        userInteractionDelegate?.didReceiveAction(
            .changeText(textView)
        )
        inputSwitcher.switchInputs(customTextView: self)

        guard textSize?.height != contentSize.height else { return }
        textSize = contentSize
        delegate?.sizeChanged()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        inputSwitcher.textViewChange = nil
    }
}
