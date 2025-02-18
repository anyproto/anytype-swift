import Foundation
import UIKit
import Factory

enum ChatInputLinkParserChange: Equatable {
    case addLinkStyle(range: NSRange, link: URL)
}

protocol ChatInputLinkParserProtocol: AnyObject {
    func handleInput(sourceText: NSAttributedString, range: NSRange, replacementText: String) -> ChatInputLinkParserChange?
    func handlePaste(text: String) -> [ChatInputLinkParserChange]
}

final class ChatInputLinkParser: ChatInputLinkParserProtocol {
    
    private let regex = try? NSRegularExpression(
        pattern: "([a-zA-Z]+:\\/\\/[^\\s/$.?#].[^\\s]*)",
        options: .caseInsensitive
    )
    
    // MARK: - ChatInputLinkParserProtocol
    
    func handleInput(
        sourceText: NSAttributedString,
        range: NSRange,
        replacementText: String
    ) -> ChatInputLinkParserChange? {
        guard let regex else { return nil }
        
        guard replacementText == " " || replacementText == "\n" else { return nil }
        
        let replacedAttributedText = sourceText.mutable
        replacedAttributedText.replaceCharacters(in: range, with: replacementText)
        
        let replacedText = replacedAttributedText.string

        let matches = regex.matches(
            in: replacedText,
            options: [],
            range: NSRange(location: 0, length: range.location + replacementText.count)
        )
        
        let textLenDiff = replacedText.count - sourceText.string.count
        guard let match = matches.last, match.range.contains(range.location - textLenDiff) else { return nil }
        
        let link = (replacedText as NSString).substring(with: match.range).lowercased()
    
        guard let linkUrl = URL(string: link) else { return nil }
        
        return .addLinkStyle(range: match.range, link: linkUrl)
    }
        
    func handlePaste(text: String) -> [ChatInputLinkParserChange] {
        guard let regex else { return [] }
        
        let matches = regex.matches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: text.count)
        )
        
        let changes = matches.compactMap { match -> ChatInputLinkParserChange? in
            let link = (text as NSString).substring(with: match.range).lowercased()
            guard let linkUrl = URL(string: link) else { return nil }
            return .addLinkStyle(range: match.range, link: linkUrl)
        }
        
        return changes
    }
}

extension Container {
    var chatInputLinkParser: Factory<any ChatInputLinkParserProtocol> {
        self { ChatInputLinkParser() }
    }
}
