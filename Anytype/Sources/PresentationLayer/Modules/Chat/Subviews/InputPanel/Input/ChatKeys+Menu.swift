import Foundation
import Services

struct ChatMenuItemInfo {
    let title: String
    let icon: ImageAsset
    let markupType: MarkupType
}

extension NSAttributedString.Key {
    
    static let chatToggleMenuKeys: [NSAttributedString.Key] = [
        .chatBold,
        .chatItalic,
        .chatKeyboard,
        .chatStrikethrough,
        .chatUnderscored
    ]
    
    func chatToggleMenuItemInfo() -> ChatMenuItemInfo? {
        switch self {
        case .chatBold:
            return ChatMenuItemInfo(title: Loc.TextStyle.Bold.title, icon: .TextStyles.bold, markupType: .bold)
        case .chatItalic:
            return ChatMenuItemInfo(title: Loc.TextStyle.Italic.title, icon: .TextStyles.italic, markupType: .italic)
        case .chatKeyboard:
            return ChatMenuItemInfo(title: Loc.TextStyle.Code.title, icon: .TextStyles.code, markupType: .keyboard)
        case .chatStrikethrough:
            return ChatMenuItemInfo(title: Loc.TextStyle.Strikethrough.title, icon: .TextStyles.strikethrough, markupType: .strikethrough)
        case .chatUnderscored:
            return ChatMenuItemInfo(title: Loc.TextStyle.Underline.title, icon: .TextStyles.underline, markupType: .underscored)
        default:
            return nil
        }
    }
}
