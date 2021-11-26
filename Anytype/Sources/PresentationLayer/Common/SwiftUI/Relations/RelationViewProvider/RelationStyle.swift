import SwiftUI

enum RelationStyle {
    case regular(allowMultiLine: Bool)
    case featuredRelationBlock(allowMultiLine: Bool)
}

extension RelationStyle {
    var font: AnytypeFont {
        switch self {
        case .regular:
            return .relation2Regular
        case .featuredRelationBlock:
            return .relation1Regular
        }
    }

    var fontColor: Color {
        switch self {
        case .regular:
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
        }
    }
}
