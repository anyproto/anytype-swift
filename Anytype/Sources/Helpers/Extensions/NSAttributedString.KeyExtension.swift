
import UIKit

extension NSAttributedString.Key {
    static let mention = NSAttributedString.Key("Mention") // Value for this key should be page Id
    
    /// Closure can be used to validate value by key in NSAttributedString
    var valueChecker: (Any?) -> Bool {
        switch self {
        case .font:
            return { $0 is UIFont}
        case .paragraphStyle:
            return { $0 is NSParagraphStyle}
        case .mention,
             .textEffect:
            return { $0 is String }
        case .link:
            return { $0 is URL }
        case .backgroundColor,
             .foregroundColor,
             .strikethroughStyle,
             .underlineStyle,
             .strokeColor:
            return { $0 is UIColor }
        case .kern,
             .tracking,
             .strokeWidth,
             .obliqueness,
             .expansion:
            return {
                guard let value = $0 as? Float, !value.isZero else {
                    return false
                }
                return true
            }
        case .shadow:
            return { $0 is NSShadow }
        case .ligature,
             .strikethroughStyle,
             .underlineStyle:
            return {
                guard let value = $0 as? Int, value != 0 else {
                    return false
                }
                return true
            }
        case .attachment:
            return { $0 is NSTextAttachment }
        case .writingDirection:
            return { $0 is [Int] }
        case .verticalGlyphForm:
            return { $0 is Int }
        default:
            return { _ in false }
        }
    }
}
