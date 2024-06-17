import Foundation
import Services

enum MarupViewAction {
    case toggleMarkup(MarkupViewType)
    case selectAlignment(LayoutAlignment)
}

struct MarkupViewsState {
    let markup: [MarkupViewType: AttributeState]
    let alignment: [LayoutAlignment: AttributeState]
}

enum MarkupViewType {
    case bold
    case italic
    case keyboard
    case strikethrough
    case link
    case underline
}

extension MarkupType {
    
    var toMarkupViewType: MarkupViewType? {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .keyboard:
            return .keyboard
        case .strikethrough:
            return .strikethrough
        case .link, .linkToObject:
            return .link
        case .underscored:
            return .underline
        case .emoji, .textColor, .backgroundColor, .mention:
            return nil
        }
    }
}
