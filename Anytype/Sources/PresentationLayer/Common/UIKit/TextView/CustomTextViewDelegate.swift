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
    func changeCaretPosition(_ range: NSRange)

    @discardableResult
    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool
}
