import BlocksModels


enum BlockOtherAction: CaseIterable {
    case lineDivider
    case dotsDivider
    
    var title: String {
        switch self {
        case .dotsDivider:
            return "Dots divider".localized
        case .lineDivider:
            return "Line divider".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .dotsDivider:
            return ImageName.slashMenu.other.dots_divider
        case .lineDivider:
            return ImageName.slashMenu.other.line_divider
        }
    }
    
    var blockViewsType: BlockContentType {
        switch self {
        case .dotsDivider:
            return .divider(.dots)
        case .lineDivider:
            return .divider(.line)
        }
    }
}
