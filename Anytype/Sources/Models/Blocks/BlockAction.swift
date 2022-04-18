
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
            return "Delete".localized
        case .duplicate:
            return "Duplicate".localized
        case .copy:
            return "Copy".localized
        case .paste:
            return "Paste".localized
//        case .move:
//            return "Move".localized
        case .moveTo:
            return "Move to".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .delete:
            return ImageName.slashMenu.actions.delete
        case .duplicate:
            return ImageName.slashMenu.actions.duplicate
        case .copy:
            return ImageName.slashMenu.actions.copy
        case .paste:
            return ImageName.slashMenu.actions.paste
//        case .move:
//            return ImageName.slashMenu.actions.move
        case .moveTo:
            return ImageName.slashMenu.actions.moveTo
        }
    }
}
