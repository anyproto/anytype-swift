import BlocksModels


enum SlashActionStyle: CaseIterable {
    case text
    case title
    case heading
    case subheading
    case highlighted
    case callout
    case checkbox
    case bulleted
    case numberedList
    case toggle
    case bold
    case italic
    case strikethrough
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
        case .callout:
            return "Callout".localized
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
        case .strikethrough:
            return "Strikethrough".localized
        case .code:
            return "Code".localized
        case .link:
            return "Link".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .text:
            return ImageName.slashMenu.style.text
        case .title:
            return ImageName.slashMenu.style.title
        case .heading:
            return ImageName.slashMenu.style.heading
        case .subheading:
            return ImageName.slashMenu.style.subheading
        case .highlighted:
            return ImageName.slashMenu.style.highlighted
        case .callout:
            return ImageName.slashMenu.style.callout
        case .checkbox:
            return ImageName.slashMenu.style.checkbox
        case .bulleted:
            return ImageName.slashMenu.style.bulleted
        case .numberedList:
            return ImageName.slashMenu.style.numbered
        case .toggle:
            return ImageName.slashMenu.style.toggle
        case .bold:
            return ImageName.slashMenu.style.bold
        case .italic:
            return ImageName.slashMenu.style.italic
        case .strikethrough:
            return ImageName.slashMenu.style.strikethrough
        case .code:
            return ImageName.slashMenu.style.code
        case .link:
            return ImageName.slashMenu.style.link
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
            return "Spotlight, that needs special attention".localized
        case .callout:
            return "Any action or idea".localized
        case .checkbox:
            return "Checkbox block subtitle".localized
        case .bulleted:
            return "Bulleted block subtitle".localized
        case .numberedList:
            return "Numbered block subtitle".localized
        case .toggle:
            return "Toggle block subtitle".localized
        case .bold, .italic, .strikethrough, .code, .link:
            return nil
        }
    }
    
    var blockViewsType: BlockContentType? {
        switch self {
        case .text:
            return .text(.text)
        case .title:
            return .text(.header)
        case .heading:
            return .text(.header2)
        case .subheading:
            return .text(.header3)
        case .highlighted:
            return .text(.quote)
        case .callout:
            return .text(.callout)
        case .checkbox:
            return .text(.checkbox)
        case .bulleted:
            return .text(.bulleted)
        case .numberedList:
            return .text(.numbered)
        case .toggle:
            return .text(.toggle)
        case .code:
            return .text(.code)
        case .bold, .italic, .strikethrough, .link:
            return nil
        }
    }
}
