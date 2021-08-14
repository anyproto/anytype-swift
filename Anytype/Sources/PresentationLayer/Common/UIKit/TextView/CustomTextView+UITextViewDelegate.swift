import UIKit


extension CustomTextView: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard options.createNewBlockOnEnter else { return true }

        let keyAction = CustomTextView.UserAction.KeyboardAction.convert(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        )

        if let keyAction = keyAction {
            if case let .enterInsideContent(currentText, _) = keyAction {
                self.textView.text = currentText
            }
            guard delegate?.didReceiveAction(
                .keyboardAction(keyAction)
            ) ?? true else { return false }
        } else {
            guard delegate?.didReceiveAction(
                .shouldChangeText(
                    range: range,
                    replacementText: text,
                    mentionsHolder: textView
                )
            ) ?? true else { return false }
        }
        accessoryViewSwitcher?.textWillChange(textView: textView, replacementText: text, range: range)

        return true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        accessoryViewSwitcher?.selectionDidChange(textView: textView)

        if textView.isFirstResponder {
            delegate?.didReceiveAction(
                .changeCaretPosition(textView.selectedRange)
            )
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        accessoryViewSwitcher?.didBeginEditing(textView: textView)
        delegate?.willBeginEditing()

        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textSize = textView.intrinsicContentSize
        delegate?.didBeginEditing()
    }

    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.intrinsicContentSize

        accessoryViewSwitcher?.textDidChange(textView: textView)

        delegate?.didReceiveAction(
            .changeText(textView.attributedText)
        )

        guard textSize?.height != contentSize.height else { return }
        textSize = contentSize
        delegate?.sizeChanged()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        accessoryViewSwitcher?.didEndEditing(textView: textView)
    }
}
