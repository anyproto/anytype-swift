import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterAtTheBeginingOfContent(String)
        case enterInsideContent(position: Int)
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
            
            let position = String(textView.text[..<range.lowerBound]).count
            return .enterInsideContent(position: position)
        }
        
        if textView.text == emptyString, replacement == emptyString, isEmpty {
            return .deleteOnEmptyContent
        }
        
        if replacement == emptyString, isEmpty {
            return .deleteAtTheBeginingOfContent
        }
        
        return nil
    }
}
