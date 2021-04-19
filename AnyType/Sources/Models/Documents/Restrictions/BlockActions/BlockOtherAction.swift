
enum BlockOtherAction: CaseIterable {
    case lineDivider
    case dotsDivider
    
    var blockViewsType: BlocksViews.Toolbar.BlocksTypes {
        switch self {
        case .dotsDivider:
            return .other(.dotsDivider)
        case .lineDivider:
            return .other(.lineDivider)
        }
    }
}
