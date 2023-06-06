import Services
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
    
    var imageAsset: ImageAsset {
        switch self {
        case .text:
            return .X40.text
        case .title:
            return .X40.title
        case .heading:
            return .X40.heading
        case .subheading:
            return .X40.subheading
        case .highlighted:
            return .X40.highlighted
        case .callout:
            return .X40.callout
        case .checkbox:
            return .X40.checkbox
        case .bulleted:
            return .X40.bulleted
        case .numberedList:
            return .X40.numbered
        case .toggle:
            return .X40.toggle
        case .bold:
            return .X40.bold
        case .italic:
            return .X40.italic
        case .strikethrough:
            return .X40.strikethrough
        case .code:
            return .X40.code
        case .link:
            return .X40.link
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
