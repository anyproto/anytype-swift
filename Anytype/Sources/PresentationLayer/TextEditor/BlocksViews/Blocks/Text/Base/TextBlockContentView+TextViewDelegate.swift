import AnytypeCore
import UIKit
import BlocksModels

extension TextBlockContentView: CustomTextViewDelegate {

    func shouldPaste(range: NSRange) -> Bool {
        actions?.shouldPaste(range, textView.textView) ?? true
    }

    func copy(range: NSRange) {
        actions?.copy(range)
    }

    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange) {
        switch change {
        case .become:
            actions?.becomeFirstResponder()
        case .resign:
            actions?.resignFirstResponder()
        }
    }
    
    func willBeginEditing() {
        actions?.textViewWillBeginEditing(textView.textView)
    }

    func didBeginEditing() {
        actions?.textViewDidBeginEditing(textView.textView)
    }
    
    func didEndEditing() {
        actions?.textViewDidEndEditing(textView.textView)
    }

    func textViewDidChangeText(_ textView: UITextView) {
        actions?.textViewDidChangeText(textView)

        if textView.isLayoutNeeded {
            actions?.textBlockSetNeedsLayout(textView)
        }
    }
    
    func changeTextStyle(attribute: MarkupType, range: NSRange) {
        actions?.changeTextStyle(attribute, range)
    }
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction) {        
        actions?.handleKeyboardAction(action, textView.textView)
    }
    
    func showPage(blockId: BlockId) {
        guard
            let details = ObjectDetailsStorage.shared.get(id: blockId)
        else {
            // Deleted objects goes here
            return
        }
        
        if !details.isArchived && !details.isDeleted {
            actions?.showPage(
                EditorScreenData(pageId: details.id, type: details.editorViewType)
            )
        }
    }
    
    func openURL(_ url: URL) {
        actions?.openURL(url)
    }
    
    func changeCaretPosition(_ range: NSRange) {
        actions?.textViewDidChangeCaretPosition(range)
    }
    
    func shouldChangeText(range: NSRange, replacementText: String) -> Bool {
        actions?.textViewShouldReplaceText(textView.textView, replacementText, range) ?? false
    }
}
