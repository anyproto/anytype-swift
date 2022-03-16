import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterForEmpty
        case enterInside(string: NSAttributedString, NSRange)
        case enterAtTheEnd(string: NSAttributedString, NSRange)
        case enterAtTheBegining(string: NSAttributedString, NSRange)
        
        case delete
    }
}

extension CustomTextView.KeyboardAction {
    private static let newLine = "\n"
    private static let emptyString = ""
    
    static func build(attributedText: NSAttributedString, nsRange: NSRange, replacement: String) -> Self? {
        let text = attributedText.string
        guard let range = Range(nsRange, in: text) else { return nil }

        let emptyRange = range.isEmpty && range.lowerBound == text.startIndex

        if replacement == newLine {
            if emptyRange && text.isEmpty {
                return .enterForEmpty
            }

            if text.endIndex == range.upperBound {
                return .enterAtTheEnd(string: attributedText, nsRange)
            }
            
            if text.startIndex == range.lowerBound {
                return .enterAtTheBegining(string: attributedText, nsRange)
            }
            
            return .enterInside(string: attributedText, nsRange)
        }
        
        if replacement == emptyString, emptyRange {
            return .delete
        }
        
        return nil
    }
}
