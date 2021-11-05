import UIKit
import BlocksModels

enum MarkStyleAction: Equatable {
    case bold(Bool)
    case italic(Bool)
    case keyboard(Bool)
    case strikethrough(Bool)
    case underscored(Bool)
    case textColor(UIColor)
    case backgroundColor(UIColor)
    case link(URL?)
    case linkToObject(BlockId)
    case mention(MentionData)
    
}

extension TextAttributesType {
    func marksStyleAction(shouldApplyMarkup: Bool) -> MarkStyleAction {
        switch self {
        case .bold:
            return .bold(shouldApplyMarkup)
        case .italic:
            return .italic(shouldApplyMarkup)
        case .keyboard:
            return .keyboard(shouldApplyMarkup)
        case .strikethrough:
            return .strikethrough(shouldApplyMarkup)
        }
    }
}
