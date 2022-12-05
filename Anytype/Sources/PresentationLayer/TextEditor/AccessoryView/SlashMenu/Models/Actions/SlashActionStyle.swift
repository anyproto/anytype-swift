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
                .withTintColor(.buttonActive)
        case .title:
            return UIImage(asset: .slashMenuStyleTitle)?
                .withTintColor(.buttonActive)
        case .heading:
            return UIImage(asset: .slashMenuStyleHeading)?
                .withTintColor(.buttonActive)
        case .subheading:
            return UIImage(asset: .slashMenuStyleSubheading)?
                .withTintColor(.buttonActive)
        case .highlighted:
            return UIImage(asset: .slashMenuStyleHighlighted)
        case .callout:
            return UIImage(asset: .slashMenuStyleCallout)
        case .checkbox:
            return UIImage(asset: .slashMenuStyleCheckbox)
        case .bulleted:
            return UIImage(asset: .slashMenuStyleBulleted)?
                .withTintColor(.buttonActive)
        case .numberedList:
            return UIImage(asset: .slashMenuStyleNumbered)?
                .withTintColor(.buttonActive)
        case .toggle:
            return UIImage(asset: .slashMenuStyleToggle)?
                .withTintColor(.buttonActive)
        case .bold:
            return UIImage(asset: .slashMenuStyleBold)?
                .withTintColor(.buttonActive)
        case .italic:
            return UIImage(asset: .slashMenuStyleItalic)?
                .withTintColor(.buttonActive)
        case .strikethrough:
            return UIImage(asset: .slashMenuStyleStrikethrough)?
                .withTintColor(.buttonActive)
        case .code:
            return UIImage(asset: .slashMenuStyleCode)?
                .withTintColor(.buttonActive)
        case .link:
            return UIImage(asset: .slashMenuStyleLink)?
                .withTintColor(.buttonActive)
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
