import UIKit
import BlocksModels

enum CustomTextViewFirstResponderChange {
    case become
    case resign
}

struct PastboardSlots {
    let textSlot: String?
    let htmlSlot: String?
    let anySlot: String?
    let fileSlot: Data?
}

protocol CustomTextViewDelegate: AnyObject {
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange)
    func willBeginEditing()
    func didBeginEditing()
    func didEndEditing()
    func textViewDidChangeText(_ textView: UITextView)
    
    func openURL(_ url: URL)
    func showPage(blockId: BlockId)
    func changeCaretPosition(_ range: NSRange)
    func changeTextStyle(attribute: MarkupType, range: NSRange)
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction)
    func shouldChangeText(range: NSRange, replacementText: String) -> Bool

    func paste(slots: PastboardSlots, range: NSRange)
}
