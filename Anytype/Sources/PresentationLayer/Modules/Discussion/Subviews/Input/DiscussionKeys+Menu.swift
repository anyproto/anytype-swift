import Foundation
import Services

struct DiscussionMenuItemInfo {
    let markText: String
    let unmarkText: String
    let markupType: MarkupType
}

extension NSAttributedString.Key {
    
    static let discussionMenuKeys: [NSAttributedString.Key] = [
        .discussionBold,
        .discussionItalic,
        .discussionKeyboard,
        .discussionStrikethrough,
        .discussionUnderscored
    ]
    
    // TODO: Temporary text - replace to filnal text or icons
    func discussionMenuItemInfo() -> DiscussionMenuItemInfo? {
        switch self {
        case .discussionBold:
            return DiscussionMenuItemInfo(markText: "Bold", unmarkText: "R Bold", markupType: .bold)
        case .discussionItalic:
            return DiscussionMenuItemInfo(markText: "Italic", unmarkText: "R Italic", markupType: .italic)
        case .discussionKeyboard:
            return DiscussionMenuItemInfo(markText: "Keyboard", unmarkText: "R Keyboard", markupType: .keyboard)
        case .discussionStrikethrough:
            return DiscussionMenuItemInfo(markText: "Strikethrough", unmarkText: "R Strikethrough", markupType: .strikethrough)
        case .discussionUnderscored:
            return DiscussionMenuItemInfo(markText: "Underscored", unmarkText: "R Underscored", markupType: .underscored)
        default:
            return nil
        }
    }
}
