
import UIKit

extension NSAttributedString.Key {
    static let linkToObject = NSAttributedString.Key("LinkToObject")
    static let mention = NSAttributedString.Key("Mention")
    static let emoji = NSAttributedString.Key("Emoji")
    /// Used to underline characters without sending markup to middleware, value should be Bool, only "true" will underline text
    static let localUnderline = NSAttributedString.Key("LocalUnderline")
    
    /// Method can be used to validate value by key in NSAttributedString
    func checkValue(_ value: Any?) -> Bool {
        switch self {
        case .font:
            return value is UIFont
        case .paragraphStyle:
            return value is NSParagraphStyle
        case .mention,
             .linkToObject,
             .textEffect:
            return value is String
        case .link:
            return value is URL
        case .backgroundColor,
             .foregroundColor,
             .strikethroughStyle,
             .underlineStyle,
             .strokeColor:
            return value is UIColor
        case .kern,
             .tracking,
             .strokeWidth,
             .obliqueness,
             .expansion:
            guard let value = value as? Float, !value.isZero else {
                return false
            }
            return true
        case .shadow:
            return value is NSShadow
        case .ligature,
             .strikethroughStyle,
             .underlineStyle:
            guard let value = value as? Int, value != 0 else {
                return false
            }
            return true
        case .attachment:
            return value is NSTextAttachment
        case .writingDirection:
            return value is [Int]
        case .verticalGlyphForm:
            return value is Int
        case .localUnderline:
            guard let value = value as? Bool, value else {
                return false
            }
            return true
        default:
            return false
        }
    }
}
