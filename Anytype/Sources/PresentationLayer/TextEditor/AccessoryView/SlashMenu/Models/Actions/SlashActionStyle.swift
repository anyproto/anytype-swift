import BlocksModels
import UIKit

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
    
    var image: UIImage? {
        switch self {
        case .text:
            return UIImage(asset: .slashMenuStyleText)?
                .withTintColor(.Button.active)
        case .title:
            return UIImage(asset: .slashMenuStyleTitle)?
                .withTintColor(.Button.active)
        case .heading:
            return UIImage(asset: .slashMenuStyleHeading)?
                .withTintColor(.Button.active)
        case .subheading:
            return UIImage(asset: .slashMenuStyleSubheading)?
                .withTintColor(.Button.active)
        case .highlighted:
            return UIImage(asset: .slashMenuStyleHighlighted)
        case .callout:
            return UIImage(asset: .slashMenuStyleCallout)
        case .checkbox:
            return UIImage(asset: .slashMenuStyleCheckbox)
        case .bulleted:
            return UIImage(asset: .slashMenuStyleBulleted)?
                .withTintColor(.Button.active)
        case .numberedList:
            return UIImage(asset: .slashMenuStyleNumbered)?
                .withTintColor(.Button.active)
        case .toggle:
            return UIImage(asset: .slashMenuStyleToggle)?
                .withTintColor(.Button.active)
        case .bold:
            return UIImage(asset: .slashMenuStyleBold)?
                .withTintColor(.Button.active)
        case .italic:
            return UIImage(asset: .slashMenuStyleItalic)?
                .withTintColor(.Button.active)
        case .strikethrough:
            return UIImage(asset: .slashMenuStyleStrikethrough)?
                .withTintColor(.Button.active)
        case .code:
            return UIImage(asset: .slashMenuStyleCode)?
                .withTintColor(.Button.active)
        case .link:
            return UIImage(asset: .slashMenuStyleLink)?
                .withTintColor(.Button.active)
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
