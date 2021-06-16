import UIKit


extension CustomTextView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard createNewBlockOnEnter else { return true }

        // In the case of frequent pressing of enter
        // we can send multiple split requests to middle
        // from the same block, it will leads to wrong order of blocks in array,
        // adding a delay in UITextView makes impossible to press enter very often
        inputSwitcher.textViewChange = textView.textChangeType(changeTextRange: range, replacementText: text)

        if text == "\n" && !pressingEnterTimeChecker.exceedsTimeInterval() {
            return false
        }
        
        userInteractionDelegate?.didReceiveAction(
            .shouldChangeText(
                range: range,
                replacementText: text,
                mentionsHolder: textView
            )
        )

        CustomTextView.UserAction.KeyboardAction.convert(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        ).flatMap {
            userInteractionDelegate?.didReceiveAction(
                CustomTextView.UserAction.keyboardAction($0)
            )
        }

        if text == "\n" {
            // we should return false and perform update by ourselves.
            switch (textView.text, range) {
            case (_, .init(location: 0, length: 0)):
                /// At the beginning
                /// We shouldn't set text, of course.
                /// It is correct logic only if we insert new text below our text.
                /// For now, we insert text above our text.
                ///
                /// TODO: Uncomment when you set split to type `.bottom`, not `.top`.
                /// textView.text = ""
                // "We only should remove text if our split operation will insert blocks at bottom, not a top. At top it works without resetting text."
                return false
            case let (source, at) where source?.count == at.location + at.length:
                return false
            case let (source, at):
                if let source = source, let theRange = Range(at, in: source) {
                    textView.text = source.replacingCharacters(in: theRange, with: "\n").split(separator: "\n").first.flatMap(String.init)
                }
                return false
            }
        }
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
            .changeText(textView.attributedText)
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
