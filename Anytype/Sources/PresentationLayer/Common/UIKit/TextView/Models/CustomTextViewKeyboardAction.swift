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
        if replacement == newLine {
            if range == .zero {
                return .enterAtTheBeginingOfContent(textView.text)
            }
            
            if textView.text.count == range.location + range.length {
                return .enterAtTheEndOfContent
            }
            
            let spitedText = splitText(text: textView.text, range: range)
            return .enterInsideContent(left: spitedText.left, right: spitedText.right)
        }
        
        if textView.text == emptyString, replacement == emptyString, range == .zero {
            return .deleteOnEmptyContent
        }
        
        if replacement == emptyString, range == .zero {
            return .deleteAtTheBeginingOfContent
        }
        
        return nil
    }
    
    private static func splitText(text: String, range: NSRange) -> (left: String, right: String) {
        let left = text.prefix(range.location)
        let rightStart = text.index(text.startIndex, offsetBy: range.location + range.length)
        let right = text[rightStart..<text.endIndex]
        return (String(left), String(right))
    }
}
