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
    case underline
    case code
    case link
    
    var title: String {
        switch self {
        case .text:
            return Loc.TextStyle.Text.title
        case .title:
            return Loc.TextStyle.Title.title
        case .heading:
            return Loc.TextStyle.Heading.title
        case .subheading:
            return Loc.TextStyle.Subheading.title
        case .highlighted:
            return Loc.TextStyle.Highlighted.title
        case .callout:
            return Loc.TextStyle.Callout.title
        case .checkbox:
            return Loc.TextStyle.Checkbox.title
        case .bulleted:
            return Loc.TextStyle.Bulleted.title
        case .numberedList:
            return Loc.TextStyle.Numbered.title
        case .toggle:
            return Loc.TextStyle.Toggle.title
        case .bold:
            return Loc.TextStyle.Bold.title
        case .italic:
            return Loc.TextStyle.Italic.title
        case .strikethrough:
            return Loc.TextStyle.Strikethrough.title
        case .underline:
            return Loc.TextStyle.Underline.title
        case .code:
            return Loc.TextStyle.Code.title
        case .link:
            return Loc.TextStyle.Link.title
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
        case .underline:
            return .X40.underline
        case .code:
            return .X40.code
        case .link:
            return .X40.link
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
        case .bold, .italic, .strikethrough, .link, .underline:
            return nil
        }
    }
}
