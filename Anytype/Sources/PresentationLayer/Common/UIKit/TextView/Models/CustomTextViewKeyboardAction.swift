import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterAtTheBeginingOfContent(String)
        case enterInsideContent(left: String?, right: String?)
        case enterAtTheEndOfContent
        
        case deleteAtTheBeginingOfContent
        case deleteOnEmptyContent
    }
}

extension CustomTextView.KeyboardAction {
    private static let newLine = "\n"
    private static let emptyString = ""
    
    static func build(
        textView: UITextView,
        range: NSRange,
        replacement: String
    ) -> Self? {
        guard let range = Range(range, in: textView.text) else { return nil }

        let isEmpty = range.isEmpty && range.lowerBound == textView.text.startIndex

        if replacement == newLine {
            if isEmpty {
                return .enterAtTheBeginingOfContent(textView.text)
            }

            if textView.text.endIndex == range.upperBound {
                return .enterAtTheEndOfContent
            }
            
            let spitedText = splitText(text: textView.text, range: range)
            return .enterInsideContent(left: spitedText.left, right: spitedText.right)
        }
        
        if textView.text == emptyString, replacement == emptyString, isEmpty {
            return .deleteOnEmptyContent
        }
        
        if replacement == emptyString, isEmpty {
            return .deleteAtTheBeginingOfContent
        }
        
        return nil
    }
    
    private static func splitText(text: String, range: Range<String.Index>) -> (left: String, right: String) {
        let left = text[..<range.lowerBound]
        let right = text[range.upperBound...]
        return (String(left), String(right))
    }
}
