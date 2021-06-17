
import BlocksModels

enum BlockAlignmentAction: CaseIterable {
    case right
    case center
    case left
    
    var blockAlignment: BlockInformationAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }
    
    var title: String {
        switch self {
        case .left:
            return "Align left".localized
        case .center:
            return "Align center".localized
        case .right:
            return "Align right".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .left:
            return "TextEditor/Toolbar/Blocks/AlignmentLeft"
        case .center:
            return "TextEditor/Toolbar/Blocks/AlignmentCenter"
        case .right:
            return "TextEditor/Toolbar/Blocks/AlignmentRight"
        }
    }
}
