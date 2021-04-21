
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
    
    var title: String {
        switch self {
        case .text:
            return "Text".localized
        case .title:
            return "Title".localized
        case .heading:
            return "Heading".localized
        case .subheading:
            return "Subheading".localized
        case .highlighted:
            return "Highlighted".localized
        case .checkbox:
            return "Checkbox".localized
        case .bulleted:
            return "Bulleted".localized
        case .numberedList:
            return "Numbered list".localized
        case .toggle:
            return "Toggle".localized
        case .bold:
            return "Bold".localized
        case .italic:
            return "Italic".localized
        case .breakthrough:
            return "Breakthrough".localized
        case .code:
            return "Code".localized
        case .link:
            return "Link".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .text:
            return "TextEditor/Toolbar/Blocks/Text"
        case .title:
            return "TextEditor/Toolbar/Blocks/Title"
        case .heading:
            return "TextEditor/Toolbar/Blocks/Heading"
        case .subheading:
            return "TextEditor/Toolbar/Blocks/Subheading"
        case .highlighted:
            return "TextEditor/Toolbar/Blocks/Highlighted"
        case .checkbox:
            return "TextEditor/Toolbar/Blocks/Checkbox"
        case .bulleted:
            return "TextEditor/Toolbar/Blocks/Bulleted"
        case .numberedList:
            return "TextEditor/Toolbar/Blocks/Numbered"
        case .toggle:
            return "TextEditor/Toolbar/Blocks/Toggle"
        case .bold:
            return "TextEditor/Toolbar/Blocks/Bold"
        case .italic:
            return "TextEditor/Toolbar/Blocks/Italic"
        case .breakthrough:
            return "TextEditor/Toolbar/Blocks/Strikethrough"
        case .code:
            return "TextEditor/Toolbar/Blocks/Code"
        case .link:
            return "TextEditor/Toolbar/Blocks/Link"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .text:
            return "Text block subtitle".localized
        case .title:
            return "Title block subtitle".localized
        case .heading:
            return "Heading block subtitle".localized
        case .subheading:
            return "Subheading block subtitle".localized
        case .highlighted:
            return "Highlighted block subtitle".localized
        case .checkbox:
            return "Checkbox block subtitle".localized
        case .bulleted:
            return "Bulleted block subtitle".localized
        case .numberedList:
            return "Numbered block subtitle".localized
        case .toggle:
            return "Toggle block subtitle".localized
        case .bold, .italic, .breakthrough, .code, .link:
            return nil
        }
    }
    
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
