import Foundation

extension TextBlockContentConfiguration.Actions {
    init(handler: TextBlockActionHandler) {
        self.init(
            shouldPaste: handler.shouldPaste(range:textView:),
            copy: handler.copy(range:),
            createEmptyBlock: handler.createEmptyBlock,
            showPage: handler.showPage,
            openURL: handler.openURL,
            changeTextStyle: handler.changeStyle(type:on:),
            handleKeyboardAction: handler.handleKeyboardAction(action:textView:),
            becomeFirstResponder: { },
            resignFirstResponder: { },
            textBlockSetNeedsLayout: handler.textBlockSetNeedsLayout(textView:),
            textViewDidChangeText: handler.textViewDidChangeText(textView:),
            textViewWillBeginEditing: handler.textViewWillBeginEditing(textView:),
            textViewDidBeginEditing: handler.textViewDidBeginEditing(textView:),
            textViewDidEndEditing: handler.textViewDidEndEditing(textView:),
            textViewDidChangeCaretPosition: handler.textViewDidChangeCaretPosition(range:),
            textViewShouldReplaceText: handler.textViewShouldReplaceText(textView:replacementText:range:),
            toggleCheckBox: handler.toggleCheckBox,
            toggleDropDown: handler.toggleCheckBox,
            tapOnCalloutIcon: handler.showTextIconPicker
        )
    }
}
