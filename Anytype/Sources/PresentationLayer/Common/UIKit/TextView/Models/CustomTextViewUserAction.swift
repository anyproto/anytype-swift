import UIKit

extension CustomTextView {

    public enum UserAction {
        case changeText(NSAttributedString)
        case changeTextStyle(NSAttributedString, BlockHandlerActionType.TextAttributesType, NSRange)
        case changeLink(NSAttributedString, NSRange)

        case keyboardAction(KeyboardAction)
        
        case shouldChangeText(range: NSRange, replacementText: String, mentionsHolder: Mentionable)
    }
}
