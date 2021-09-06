
enum BlockAction: CaseIterable {
    case delete
    case duplicate
    case copy
    case paste
    case move
    case moveTo
    case cleanStyle
    
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
        case .move:
            return "Move".localized
        case .moveTo:
            return "Move to".localized
        case .cleanStyle:
            return "Clear style".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .delete:
            return "TextEditor/Toolbar/Blocks/Delete"
        case .duplicate:
            return "TextEditor/Toolbar/Blocks/Duplicate"
        case .copy:
            return "TextEditor/Toolbar/Blocks/Copy"
        case .paste:
            return "TextEditor/Toolbar/Blocks/Paste"
        case .move:
            return "TextEditor/Toolbar/Blocks/Move"
        case .moveTo:
            return "TextEditor/Toolbar/Blocks/MoveTo"
        case .cleanStyle:
            return "TextEditor/Toolbar/Blocks/Clear"
        }
    }
}
