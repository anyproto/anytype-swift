import AnytypeCore
import UIKit
import BlocksModels

extension TextBlockContentView: CustomTextViewDelegate {    
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
    
    func changeText(text: NSAttributedString) {
        actions?.changeText(text)

        if textView.textView.isLayoutNeeded {
            actions?.textBlockSetNeedsLayout()
        }
    }
    
    func changeTextStyle(attribute: MarkupType, range: NSRange) {
        actions?.changeTextStyle(attribute, range)
    }
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction) {
        actions?.handleKeyboardAction(action, textView.textView.attributedText)
//        switch action {
//        case .enterInsideContent,
//             .enterAtTheEndOfContent,
//             .enterAtTheBeginingOfContent:
//            // In the case of frequent pressing of enter
//            // we can send multiple split requests to middle
//            // from the same block, it will leads to wrong order of blocks in array,
//            // adding a delay makes impossible to press enter very often
////            if currentConfiguration.pressingEnterTimeChecker.exceedsTimeInterval() {
//                actions?.handleKeyboardAction(action, textView.textView.attributedText)
//
////            }
//            return false
//        case .deleteOnEmptyContent, .deleteAtTheBeginingOfContent:
//
//            handler.handleKeyboardAction(action, info: currentConfiguration.information, attributedText: textView.textView.attributedText)
//            return true
//        }
    }
    
    func showPage(blockId: BlockId) {
        guard let details = ObjectDetailsStorage.shared.get(id: blockId) else {
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
//        handler.changeCaretPosition(range: range)
//        blockDelegate.selectionDidChange(range: range)
    }
    
    func shouldChangeText(range: NSRange, replacementText: String, mentionsHolder: Mentionable) -> Bool {
        let changeType = textView.textView.textChangeType(changeTextRange: range, replacementText: replacementText)

        actions?.textViewDidApplyChangeType(changeType)
//        blockDelegate.textWillChange(changeType: changeType)
        
        let shouldChangeText = !mentionsHolder.removeMentionIfNeeded(text: replacementText)
        if !shouldChangeText {
            actions?.changeText(textView.textView.attributedText)
        }
        return shouldChangeText
    }
}
