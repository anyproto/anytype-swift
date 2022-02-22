import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterAtTheBeginingOfContent(string: NSAttributedString)
        case enterInsideContent(string: NSAttributedString, position: Int)
        case enterAtTheEndOfContent(string: NSAttributedString)
        
        case deleteAtTheBeginingOfContent
        case deleteOnEmptyContent
    }
}

extension CustomTextView.KeyboardAction {
    private static let newLine = "\n"
    private static let emptyString = ""
    
    static func build(attributedText: NSAttributedString, range: NSRange, replacement: String) -> Self? {
        let text = attributedText.string
        guard let range = Range(range, in: text) else { return nil }

        let isEmpty = range.isEmpty && range.lowerBound == text.startIndex

        if replacement == newLine {
            if isEmpty {
                if text.isEmpty {
                    return .enterAtTheEndOfContent(string: attributedText)
                } else {
                    return .enterAtTheBeginingOfContent(string: attributedText)
                }
            }

            if text.endIndex == range.upperBound {
                return .enterAtTheEndOfContent(string: attributedText)
            }
            
            let position = String(text[..<range.lowerBound]).count
            return .enterInsideContent(string: attributedText, position: position)
        }
        
        if text == emptyString, replacement == emptyString, isEmpty {
            return .deleteOnEmptyContent
        }
        
        if replacement == emptyString, isEmpty {
            return .deleteAtTheBeginingOfContent
        }
        
        return nil
    }
}
