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
    
    var markupViewType: MarkupViewType? {
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

// TODO: Delete it
extension MarkupViewType {
    
    var markupType: MarkupType {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .keyboard:
            return .keyboard
        case .strikethrough:
            return .strikethrough
        case .link:
            return .linkToObject(nil)
        }
    }
}

extension LayoutAlignment {
    var layoutAlignmentViewType: MarkupViewLayoutAlignmentType {
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
    var layoutAlignment: LayoutAlignment {
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
