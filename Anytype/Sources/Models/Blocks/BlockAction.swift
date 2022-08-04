
enum BlockAction: CaseIterable {
    case delete
    case duplicate
    case copy
    case paste
//    case move
    case moveTo
    
    var title: String {
        switch self {
        case .delete:
            return Loc.delete
        case .duplicate:
            return Loc.duplicate
        case .copy:
            return Loc.copy
        case .paste:
            return Loc.paste
//        case .move:
//            return Loc.move
        case .moveTo:
            return Loc.moveTo
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .delete:
            return .delete
        case .duplicate:
            return .slashMenuActionDuplicate
        case .copy:
            return .slashMenuActionCopy
        case .paste:
            return .slashMenuActionPaste
//        case .move:
//            return ImageName.slashMenu.actions.move
        case .moveTo:
            return .slashMenuActionMoveTo
        }
    }
}
