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
        case toggleFontStyle(TextAttributesType)
        case setAlignment(BlockInformationAlignment)
        case setLink(String)
    }
}
