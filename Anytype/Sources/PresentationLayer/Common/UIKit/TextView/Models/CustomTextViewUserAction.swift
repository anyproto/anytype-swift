import UIKit

extension CustomTextView {

    public enum UserAction {
        case changeText(NSAttributedString)
        case changeTextStyle(NSAttributedString, BlockHandlerActionType.TextAttributesType, NSRange)
    }
}
