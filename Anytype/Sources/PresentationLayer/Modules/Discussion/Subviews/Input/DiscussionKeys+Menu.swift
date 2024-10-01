import Foundation
import Services

struct DiscussionMenuItemInfo {
    let icon: ImageAsset
    let markupType: MarkupType
}

extension NSAttributedString.Key {
    
    static let discussionToggleMenuKeys: [NSAttributedString.Key] = [
        .discussionBold,
        .discussionItalic,
        .discussionKeyboard,
        .discussionStrikethrough,
        .discussionUnderscored
    ]
    
    func discussionToggleMenuItemInfo() -> DiscussionMenuItemInfo? {
        switch self {
        case .discussionBold:
            return DiscussionMenuItemInfo(icon: .TextStyles.bold, markupType: .bold)
        case .discussionItalic:
            return DiscussionMenuItemInfo(icon: .TextStyles.italic, markupType: .italic)
        case .discussionKeyboard:
            return DiscussionMenuItemInfo(icon: .TextStyles.code, markupType: .keyboard)
        case .discussionStrikethrough:
            return DiscussionMenuItemInfo(icon: .TextStyles.strikethrough, markupType: .strikethrough)
        case .discussionUnderscored:
            return DiscussionMenuItemInfo(icon: .TextStyles.underline, markupType: .underscored)
        default:
            return nil
        }
    }
}
