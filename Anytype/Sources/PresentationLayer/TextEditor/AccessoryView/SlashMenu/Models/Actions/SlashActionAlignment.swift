
import Services

enum SlashActionAlignment: CaseIterable {
    case right
    case center
    case left
    case justify
    
    var blockAlignment: LayoutAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justify:
            return .justify
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
        case .justify:
            return Loc.alignJustify
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .left:
            return .X32.Align.left
        case .center:
            return .X32.Align.center
        case .right:
            return .X32.Align.right
        case .justify:
            return .X32.Align.justify
        }
    }
}
