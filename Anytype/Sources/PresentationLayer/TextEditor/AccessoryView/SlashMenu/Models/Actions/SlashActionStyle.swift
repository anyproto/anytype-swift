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
    
    var iconAsset: ImageAsset {
        switch self {
        case .text:
            return .slashMenuStyleText
        case .title:
            return .slashMenuStyleTitle
        case .heading:
            return .slashMenuStyleHeading
        case .subheading:
            return .slashMenuStyleSubheading
        case .highlighted:
            return .slashMenuStyleHighlighted
        case .callout:
            return .slashMenuStyleCallout
        case .checkbox:
            return .slashMenuStyleCheckbox
        case .bulleted:
            return .slashMenuStyleBulleted
        case .numberedList:
            return .slashMenuStyleNumbered
        case .toggle:
            return .slashMenuStyleToggle
        case .bold:
            return .slashMenuStyleBold
        case .italic:
            return .slashMenuStyleItalic
        case .strikethrough:
            return .slashMenuStyleStrikethrough
        case .code:
            return .slashMenuStyleCode
        case .link:
            return .slashMenuStyleLink
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
