import Foundation
import Services

extension NSAttributedString.Key {
    static let chatBold = NSAttributedString.Key("chatBold")
    static let chatItalic = NSAttributedString.Key("chatItalic")
    static let chatKeyboard = NSAttributedString.Key("chatKeyboard")
    static let chatStrikethrough = NSAttributedString.Key("chatStrikethrough")
    static let chatUnderscored = NSAttributedString.Key("chatUnderscored")
    static let chatMention = NSAttributedString.Key("chatMention")
    static let chatLinkToObject = NSAttributedString.Key("chatLinkToObject")
    static let chatLinkToURL = NSAttributedString.Key("chatLinkToURL")
}

extension MarkupType {
    var chatAttributedKeyWithoutValue: NSAttributedString.Key? {
        switch self {
        case .bold:
            return .chatBold
        case .italic:
            return .chatItalic
        case .keyboard:
            return .chatKeyboard
        case .strikethrough:
            return .chatStrikethrough
        case .underscored:
            return .chatUnderscored
        default:
            return nil
        }
    }
}
