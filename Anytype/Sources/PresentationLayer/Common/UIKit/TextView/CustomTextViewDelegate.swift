import UIKit

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

    @discardableResult
    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool
}
