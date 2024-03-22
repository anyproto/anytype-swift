import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterForEmpty
        case enterInside(string: NSAttributedString, NSRange)
        case enterAtTheEnd(string: NSAttributedString, NSRange)
        case enterAtTheBegining
        
        case delete
    }
}

extension CustomTextView.KeyboardAction {
    private static let newLine = "\n"
    private static let emptyString = ""
    
    static func build(attributedText: NSAttributedString, range: NSRange, replacement: String) -> Self? {
        let text = attributedText.string
        guard let textRange = Range(range, in: text) else { return nil }
        
        let emptyRange = textRange.isEmpty && textRange.lowerBound == text.startIndex

        if replacement == newLine {
            if emptyRange && text.isEmpty {
                return .enterForEmpty
            }

            if text.endIndex == textRange.upperBound {
                return .enterAtTheEnd(string: attributedText, range)
            }
            
            if text.startIndex == textRange.lowerBound {
                return .enterAtTheBegining
            }
            
            return .enterInside(string: attributedText, range)
        }
        
        if replacement == emptyString, emptyRange {
            return .delete
        }
        
        return nil
    }
}
