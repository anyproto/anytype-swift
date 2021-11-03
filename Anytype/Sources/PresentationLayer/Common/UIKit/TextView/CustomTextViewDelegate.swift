import UIKit
import BlocksModels

enum CustomTextViewFirstResponderChange {
    case become
    case resign
}

protocol CustomTextViewDelegate: AnyObject {
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange)
    func willBeginEditing()
    func didBeginEditing()
    func didEndEditing()
    
    func openURL(_ url: URL)
    func showPage(blockId: BlockId)
    func changeText(text: NSAttributedString)
    func changeCaretPosition(_ range: NSRange)
    func changeLink(text: NSAttributedString, range: NSRange)
    func changeTextStyle(text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange)
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction) -> Bool
    func shouldChangeText(range: NSRange, replacementText: String, mentionsHolder: Mentionable) -> Bool
}
