
enum BlockStyleAction: CaseIterable {
    case text
    case title
    case heading
    case subheading
    case highlighted
    case checkbox
    case bulleted
    case numberedList
    case toggle
    case bold
    case italic
    case breakthrough
    case code
    case link
    
    var blockViewsType: BlocksViews.Toolbar.BlocksTypes? {
        switch self {
        case .text:
            return .text(.text)
        case .title:
            return .text(.h1)
        case .heading:
            return .text(.h2)
        case .subheading:
            return .text(.h3)
        case .highlighted:
            return .text(.highlighted)
        case .checkbox:
            return .list(.checkbox)
        case .bulleted:
            return .list(.bulleted)
        case .numberedList:
            return .list(.numbered)
        case .toggle:
            return .list(.toggle)
        case .code:
            return .other(.code)
        case .link:
            return .objects(.page)
        case .bold, .italic, .breakthrough:
            return nil
        }
    }
}
