import Foundation
import BlocksModels

enum MarupViewAction {
    case toggleMarkup(MarkupViewType)
    case selectAlignment(MarkupViewLayoutAlignmentType)
}

struct MarkupViewsState {
    let markup: [MarkupViewType: AttributeState]
    let alignment: [MarkupViewLayoutAlignmentType: AttributeState]
}

enum MarkupViewType {
    case bold
    case italic
    case keyboard
    case strikethrough
    case link
}

enum MarkupViewLayoutAlignmentType {
    case left
    case center
    case right
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
        case .emoji, .underscored, .textColor, .backgroundColor, .mention:
            return nil
        }
    }
}

extension LayoutAlignment {
    var toLayoutAlignmentViewType: MarkupViewLayoutAlignmentType {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }
}

extension MarkupViewLayoutAlignmentType {
    var toLayoutAlignment: LayoutAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }
}
