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
            return "TextEditor/Toolbar/Blocks/DotsDivider"
        case .lineDivider:
            return "TextEditor/Toolbar/Blocks/LineDivider"
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
