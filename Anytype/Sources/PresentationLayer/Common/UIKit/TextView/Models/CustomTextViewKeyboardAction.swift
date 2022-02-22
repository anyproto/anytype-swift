import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterForEmpty
        case enterInside(string: NSAttributedString, position: Int)
        case enterAtTheEnd(string: NSAttributedString)
        
        case deleteAtTheBegining
        case deleteForEmpty
    }
}

extension CustomTextView.KeyboardAction {
    private static let newLine = "\n"
    private static let emptyString = ""
    
    static func build(attributedText: NSAttributedString, range: NSRange, replacement: String) -> Self? {
        let text = attributedText.string
        guard let range = Range(range, in: text) else { return nil }

        let emptyRange = range.isEmpty && range.lowerBound == text.startIndex

        if replacement == newLine {
            if emptyRange && text.isEmpty {
                return .enterForEmpty
            }

            if text.endIndex == range.upperBound {
                return .enterAtTheEnd(string: attributedText)
            }
            
            let position = String(text[..<range.lowerBound]).count
            return .enterInside(string: attributedText, position: position)
        }
        
        if text == emptyString, replacement == emptyString, emptyRange {
            return .deleteForEmpty
        }
        
        if replacement == emptyString, emptyRange {
            return .deleteAtTheBegining
        }
        
        return nil
    }
}
