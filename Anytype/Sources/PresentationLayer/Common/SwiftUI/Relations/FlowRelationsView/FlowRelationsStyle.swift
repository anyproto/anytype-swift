import SwiftUI

enum FlowRelationsStyle {
    case header
    case cell
    
    var descriptionFont: AnytypeFont {
        switch self {
        case .header: return .relation2Regular
        case .cell: return .relation3Regular
        }
    }

    var descriptionColor: Color {
        switch self {
        case .header: return .textPrimary
        case .cell: return .textSecondary
        }
    }
    
    var descriptionOffset: CGFloat {
        switch self {
        case .header: return 6
        case .cell: return 4
        }
    }
    
    var headerToRelationsOffset: CGFloat {
        switch self {
        case .header: return 8
        case .cell: return 2
        }
    }
    
    var titleStyle: TitleWithIconStyle {
        switch self {
        case .header: return .header
        case .cell: return .list
        }
    }
}
