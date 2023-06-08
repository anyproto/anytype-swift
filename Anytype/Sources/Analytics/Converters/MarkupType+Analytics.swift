import Foundation

extension MarkupType {
    var analyticsValue: String {
        switch self {
        case .bold:
            return "Bold"
        case .italic:
            return "Italic"
        case .keyboard:
            return "Code"
        case .strikethrough:
            return "Strike"
        case .underscored:
            return "Underline"
        case .textColor:
            return "Color"
        case .backgroundColor:
            return "BgColor"
        case .link:
            return "Link"
        case .linkToObject:
            return "Object"
        case .mention:
            return "Mention"
        case .emoji:
            return "Emoji"
        }
    }
}
