
import BlocksModels

enum SlashActionAlignment: CaseIterable {
    case right
    case center
    case left
    
    var blockAlignment: LayoutAlignment {
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
            return Loc.alignLeft
        case .center:
            return Loc.alignCenter
        case .right:
            return Loc.alignRight
        }
    }
    
    var iconName: String {
        switch self {
        case .left:
            return ImageName.slashMenu.alignment.left
        case .center:
            return ImageName.slashMenu.alignment.center
        case .right:
            return ImageName.slashMenu.alignment.right
        }
    }
}
