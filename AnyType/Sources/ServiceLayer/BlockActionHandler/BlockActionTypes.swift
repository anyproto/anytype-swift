import UIKit
import BlocksModels

extension BlockActionHandler {
    /// Action on style view
    enum ActionType: Hashable {
        enum TextAttributesType {
            case bold
            case italic
            case strikethrough
            case keyboard
        }

        case turnInto(BlockContent.Text.ContentType)
        case setTextColor(UIColor)
        case setBackgroundColor(UIColor)
        case toggleFontStyle(TextAttributesType, NSRange = NSRange(location: 0, length: 0))
        case setAlignment(BlockInformationAlignment)
        case setLink(String)
    }
}
