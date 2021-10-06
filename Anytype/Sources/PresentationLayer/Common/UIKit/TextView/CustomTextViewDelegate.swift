import UIKit

enum CustomTextViewFirstResponderChange {
    case become
    case resign
}

protocol CustomTextViewDelegate: AnyObject {
    func sizeChanged()
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange)
    func willBeginEditing()
    func didBeginEditing()

    @discardableResult
    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool
}
