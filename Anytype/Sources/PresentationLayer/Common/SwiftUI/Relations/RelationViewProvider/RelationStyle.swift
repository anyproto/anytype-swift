import SwiftUI

enum RelationStyle {
    case regular
    case featuredRelationBlock
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
}
