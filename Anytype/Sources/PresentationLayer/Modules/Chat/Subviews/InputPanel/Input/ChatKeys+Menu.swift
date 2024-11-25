import Foundation
import Services

struct ChatMenuItemInfo {
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
            return ChatMenuItemInfo(icon: .TextStyles.bold, markupType: .bold)
        case .chatItalic:
            return ChatMenuItemInfo(icon: .TextStyles.italic, markupType: .italic)
        case .chatKeyboard:
            return ChatMenuItemInfo(icon: .TextStyles.code, markupType: .keyboard)
        case .chatStrikethrough:
            return ChatMenuItemInfo(icon: .TextStyles.strikethrough, markupType: .strikethrough)
        case .chatUnderscored:
            return ChatMenuItemInfo(icon: .TextStyles.underline, markupType: .underscored)
        default:
            return nil
        }
    }
}
