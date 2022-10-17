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
    
    func markupValue(_ markup: MarkupType, range: NSRange) -> MarkupType? {
        switch markup {
        case .bold:
            return boldState(range: range) ? .bold : nil
        case .italic:
            return italicState(range: range) ? .italic : nil
        case .keyboard:
            return codeState(range: range) ? .keyboard : nil
        case .strikethrough:
            return strikethroughState(range: range) ? .strikethrough : nil
        case .textColor:
            return colorState(range: range).map { .textColor($0) } ?? nil
        case .underscored:
            return isUnderscored(range: range) ? .underscored : nil
        case .backgroundColor:
            return backgroundColor(range: range).map { .backgroundColor($0) } ?? nil
        case .link:
            return linkState(range: range).map { .link($0) } ?? nil
        case .linkToObject:
            return linkToObjectState(range: range).map { .linkToObject($0) } ?? nil
        case .mention:
            return mention(range: range).map { .mention(MentionData.noDetails(blockId: $0)) } ?? nil
        case .emoji:
            if let emojiString = emoji(range: range), let emoji = Emoji(emojiString) {
                return .emoji(emoji)
            }
            return nil
        }
    }
    
    func hasMarkup(_ markup: MarkupType, range: NSRange) -> Bool {
        return markupValue(markup, range: range).isNotNil
    }
}
