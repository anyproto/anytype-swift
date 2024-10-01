import Foundation
import Services

extension NSAttributedString.Key {
    static let discussionBold = NSAttributedString.Key("discussionBold")
    static let discussionItalic = NSAttributedString.Key("discussionItalic")
    static let discussionKeyboard = NSAttributedString.Key("discussionKeyboard")
    static let discussionStrikethrough = NSAttributedString.Key("discussionStrikethrough")
    static let discussionUnderscored = NSAttributedString.Key("discussionUnderscored")
    static let discussionMention = NSAttributedString.Key("discussionMention")
    static let discussionLinkToObject = NSAttributedString.Key("discussionLinkToObject")
    static let discussionLinkToURL = NSAttributedString.Key("discussionLinkToURL")
}

extension MarkupType {
    var discussionAttributedKeyWithoutValue: NSAttributedString.Key? {
        switch self {
        case .bold:
            return .discussionBold
        case .italic:
            return .discussionItalic
        case .keyboard:
            return .discussionKeyboard
        case .strikethrough:
            return .discussionStrikethrough
        case .underscored:
            return .discussionUnderscored
        default:
            return nil
        }
    }
}
