import Foundation
import UIKit
import AnytypeCore

final class InlineMarkdownListener: MarkdownListener {
    
    private struct MatchResult {
        let shortcut: InlineMarkdown
        let shortcutText: InlineMarkdown.Pattern
        let text: NSAttributedString
        let range: NSRange
    }
    
    // MARK: - MarkdownListener
    
    func markdownChange(textView: UITextView, replacementText: String, range: NSRange) -> MarkdownChange? {
        
        guard FeatureFlags.inlineMarkdown else { return nil }
        
        let replacedAttributedText = textView.attributedText.mutable
        replacedAttributedText.replaceCharacters(in: range, with: replacementText)
        
        let replacedText = replacedAttributedText.string
        
        var matchResults = [MatchResult]()
        
        for shortcut in InlineMarkdown.all {
            for shortcutText in shortcut.text {
                
                guard replacedText.count >= shortcutText.count else { continue }
                
                guard let endRange = replacedText.findUniqueRangeFor(pattern: shortcutText.end, endIndex: replacedText.endIndex)
                    else { continue }
                
                guard let startRange = replacedText.findUniqueRangeFor(pattern: shortcutText.start, endIndex: endRange.lowerBound)
                    else { continue }
                
                let finalText = replacedAttributedText.mutable
                
                let endNSRange = NSRange(endRange, in: replacedText)
                let startNSRange = NSRange(startRange, in: replacedText)
                
                finalText.replaceCharacters(in: endNSRange, with: "")
                finalText.replaceCharacters(in: startNSRange, with: "")
                
                let finalRange = NSRange(
                    location: startNSRange.location,
                    length: endNSRange.location - startNSRange.location - startNSRange.length
                )
                
                let result = MatchResult(
                    shortcut: shortcut,
                    shortcutText: shortcutText,
                    text: finalText,
                    range: finalRange
                )
                
                matchResults.append(result)
            }
        }
        
        matchResults.sort { $0.shortcutText.count < $1.shortcutText.count }
        
        guard let finalResult = matchResults.first else { return nil }
        
        return .addStyle(finalResult.shortcut.markup, text: finalResult.text, range: finalResult.range)
    }
}


private extension StringProtocol {
    
    // Also check if pattern repeat more one times.
    // Example: "123**456" for pattern "*", this method return nil, because pattern repeat twise in next position.
    func findUniqueRangeFor(pattern: String, endIndex: String.Index) -> Range<String.Index>? {
        
        guard  let firstRange = range(of: pattern, options: [.backwards], range: startIndex..<endIndex) else {
            return nil
        }
        
        guard let secondRange = range(of: pattern, options: [.backwards], range: startIndex..<firstRange.lowerBound) else {
            return firstRange
        }
        
        guard distance(from: secondRange.upperBound, to: firstRange.lowerBound) != 0 else {
            return nil
        }
        
        return firstRange
    }
}
