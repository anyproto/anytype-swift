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
            return Loc.text
        case .title:
            return Loc.title
        case .heading:
            return Loc.heading
        case .subheading:
            return Loc.subheading
        case .highlighted:
            return Loc.highlighted
        case .callout:
            return Loc.callout
        case .checkbox:
            return Loc.checkbox
        case .bulleted:
            return Loc.bulleted
        case .numberedList:
            return Loc.numberedList
        case .toggle:
            return Loc.toggle
        case .bold:
            return Loc.bold
        case .italic:
            return Loc.italic
        case .strikethrough:
            return Loc.strikethrough
        case .code:
            return Loc.code
        case .link:
            return Loc.link
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
            return Loc.textBlockSubtitle
        case .title:
            return Loc.titleBlockSubtitle
        case .heading:
            return Loc.headingBlockSubtitle
        case .subheading:
            return Loc.subheadingBlockSubtitle
        case .highlighted:
            return Loc.spotlightThatNeedsSpecialAttention
        case .callout:
            return Loc.borderedTextWithIcon
        case .checkbox:
            return Loc.checkboxBlockSubtitle
        case .bulleted:
            return Loc.bulletedBlockSubtitle
        case .numberedList:
            return Loc.numberedBlockSubtitle
        case .toggle:
            return Loc.toggleBlockSubtitle
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
