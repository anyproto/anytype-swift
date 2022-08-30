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
    
    var headerToContentOffset: CGFloat {
        switch self {
        case .header: return 6
        case .cell: return 4
        }
    }
    
    var relationsOffset: CGFloat {
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
    
    var relationStyle: RelationStyle {
        switch self {
        case .header: return .featuredRelationBlock(allowMultiLine: false)
        case .cell: return .setCollection
        }
    }
    
    var relationSpacing: CGSize {
        switch self {
        case .header: return .init(width: 6, height: 4)
        case .cell: return .init(width: 6, height: 2)
        }
    }
    
    var descriptionLineLimit: Int? {
        switch self {
        case .header: return nil
        case .cell: return 1
        }
    }
}
