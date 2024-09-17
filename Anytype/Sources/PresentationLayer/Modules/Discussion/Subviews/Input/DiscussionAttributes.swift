import Foundation
import Services

extension NSAttributedString.Key {
    static let discussionBold = NSAttributedString.Key("discussionBold")
    static let discussionItalic = NSAttributedString.Key("discussionItalic")
    static let discussionKeyboard = NSAttributedString.Key("discussionKeyboard")
    static let discussionStrikethrough = NSAttributedString.Key("discussionStrikethrough")
    static let discussionUnderscored = NSAttributedString.Key("discussionUnderscored")
}

struct MessageAttribute: CodableAttributedStringKey {
    typealias Value = Bool
    static var name: String = "discussionBold"
}

extension AttributeScopes {
    struct AnytypeAttributes: AttributeScope {
        let discussionBold: MessageAttribute
        let swiftUI: SwiftUIAttributes
    }
    var anytype: AnytypeAttributes.Type { AnytypeAttributes.self }
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
