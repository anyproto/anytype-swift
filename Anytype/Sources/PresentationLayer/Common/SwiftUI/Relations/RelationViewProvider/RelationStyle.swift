import SwiftUI

enum RelationStyle {
    case regular(allowMultiLine: Bool)
    case featuredRelationBlock(allowMultiLine: Bool)
    case set
}

enum RelationPlaceholderType {
    case hint
    case empty
}

extension RelationStyle {
    var font: AnytypeFont {
        switch self {
        case .regular:
            return .relation1Regular
        case .set:
            return .relation2Regular
        case .featuredRelationBlock:
            return .relation1Regular
        }
    }

    var fontColor: Color {
        switch self {
        case .regular, .set:
            return .textPrimary
        case .featuredRelationBlock:
            return .textSecondary
        }
    }

    var allowMultiLine: Bool {
        switch self {
        case let .regular(value):
            return value
        case let .featuredRelationBlock(value):
            return value
        case .set:
            return false
        }
    }
    
    var placeholderType: RelationPlaceholderType {
        switch self {
        case .regular, .featuredRelationBlock:
            return .hint
        case .set:
            return .empty
        }
    }
    
    
    var tagViewGuidlines: TagView.Guidlines {
        switch self {
        case .regular, .set:
            return TagView.Guidlines(textPadding: 6, cornerRadius: 5, tagHeight: 24)
        case .featuredRelationBlock:
            return TagView.Guidlines(textPadding: 6, cornerRadius: 4, tagHeight: 19)
        }
    }
    
}
