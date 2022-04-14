import AnytypeCore
import UIKit
import BlocksModels

extension TextBlockContentView: CustomTextViewDelegate {

    func shouldPaste(range: NSRange) -> Bool {
        actions?.shouldPaste(range) ?? true
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
            actions?.textBlockSetNeedsLayout()
        }
    }
    
    func changeTextStyle(attribute: MarkupType, range: NSRange) {
        actions?.changeTextStyle(attribute, range)
    }
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction) {        
        actions?.handleKeyboardAction(action)
    }
    
    func showPage(blockId: BlockId) {
        guard
            let id = blockId.asAnytypeId,
            let details = ObjectDetailsStorage.shared.get(id: id)
        else {
            // Deleted objects goes here
            return
        }
        
        if !details.isArchived && !details.isDeleted {
            guard let id = details.id.asAnytypeId else { return }
            actions?.showPage(
                EditorScreenData(pageId: id, type: details.editorViewType)
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
