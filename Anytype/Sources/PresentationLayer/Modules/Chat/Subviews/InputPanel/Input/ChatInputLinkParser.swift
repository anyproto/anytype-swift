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
    
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    
    // MARK: - ChatInputLinkParserProtocol
    
    func handleInput(
        sourceText: NSAttributedString,
        range: NSRange,
        replacementText: String
    ) -> ChatInputLinkParserChange? {
        guard let detector else { return nil }
        
        guard replacementText == " " || replacementText == "\n" else { return nil }
        
        let replacedAttributedText = sourceText.mutable
        replacedAttributedText.replaceCharacters(in: range, with: replacementText)
        
        let replacedText = replacedAttributedText.string

        let matches = detector.matches(
            in: replacedText,
            options: [],
            range: NSRange(location: 0, length: range.location + replacementText.count)
        )
        
        let textLenDiff = replacedText.count - sourceText.string.count
        guard let match = matches.last, match.range.contains(range.location - textLenDiff) else { return nil }
        
        guard let linkUrl = match.url?.urlWithLowercaseScheme, !linkUrl.isEmail else { return nil }
        
        return .addLinkStyle(range: match.range, link: linkUrl)
    }
        
    func handlePaste(text: String) -> [ChatInputLinkParserChange] {
        guard let detector else { return [] }
        
        let matches = detector.matches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: text.count)
        )
        
        let changes = matches.compactMap { match -> ChatInputLinkParserChange? in
            guard let linkUrl = match.url?.urlWithLowercaseScheme, !linkUrl.isEmail else { return nil }
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
