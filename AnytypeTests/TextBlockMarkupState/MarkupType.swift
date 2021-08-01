import Foundation

enum MarkupType {
    case italic
    case bold
    case code
    case strikethrough
    
    var attributedStringKey: NSAttributedString.Key {
        switch self {
        case .italic, .bold, .code:
            return .font
        case .strikethrough:
            return .strikethroughStyle
        }
    }
}
