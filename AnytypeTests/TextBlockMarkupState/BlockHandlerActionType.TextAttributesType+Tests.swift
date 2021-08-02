@testable import Anytype
import UIKit

extension BlockHandlerActionType.TextAttributesType {
    
    var attributedStringKey: NSAttributedString.Key {
        switch self {
        case .italic, .bold, .keyboard:
            return .font
        case .strikethrough:
            return .strikethroughStyle
        }
    }
    
    var matchingAttribute: Any {
        switch self {
        case .bold:
            return UIFont.boldSystemFont(ofSize: 33)
        case .italic:
            return UIFont.italicSystemFont(ofSize: 29)
        case .keyboard:
            return UIFont.code
        case .strikethrough:
            return NSUnderlineStyle.single.rawValue
        }
    }
}
