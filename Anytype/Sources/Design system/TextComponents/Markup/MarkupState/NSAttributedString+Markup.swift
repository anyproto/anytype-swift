import AnytypeCore
import UIKit
import BlocksModels

extension NSAttributedString {
    
    func boldState(range: NSRange) -> Bool {
        return isFontInWhole(range: range, has: .traitBold)
    }
    
    func italicState(range: NSRange) -> Bool {
        return isFontInWhole(range: range, has: .traitItalic)
    }
    
    func strikethroughState(range: NSRange) -> Bool {
        guard length > 0  else { return false }
        return isEverySymbol(in: range, has: .strikethroughStyle)
    }
    
    func codeState(range: NSRange) -> Bool {
        return isCodeFontInWhole(range: range)
    }
    
    func linkState(range: NSRange) -> URL? {
        let url: URL? = value(for: .link, range: range)
        return url
    }

    func linkToObjectState(range: NSRange) -> String? {
        let objectLink: String? = value(for: .linkToObject, range: range)
        return objectLink
    }

    func colorState(range: NSRange) -> UIColor? {
        return value(for: .foregroundColor, range: range)
    }

    func backgroundColor(range: NSRange) -> UIColor? {
        return value(for: .backgroundColor, range: range)
    }

    func isUnderscored(range: NSRange) -> Bool {
        guard length > 0 else { return false }
        return isEverySymbol(in: range, has: .anytypeUnderline)
    }

    func mention(range: NSRange) -> String? {
        return value(for: .mention, range: range)
    }
    
    func emoji(range: NSRange) -> String? {
        return value(for: .emoji, range: range)
    }
    
    func hasMarkup(_ markup: MarkupType, range: NSRange) -> Bool {
        switch markup {
        case .bold:
            return boldState(range: range)
        case .italic:
            return italicState(range: range)
        case .keyboard:
            return codeState(range: range)
        case .strikethrough:
            return strikethroughState(range: range)
        case .textColor:
            return colorState(range: range).isNotNil
        case .underscored:
            return isUnderscored(range: range)
        case .backgroundColor:
            return backgroundColor(range: range).isNotNil
        case .link:
            return linkState(range: range).isNotNil
        case .linkToObject:
            return linkToObjectState(range: range).isNotNil
        case .mention:
            return mention(range: range).isNotNil
        case .emoji:
            return emoji(range: range).isNotNil
        }
    }
}
