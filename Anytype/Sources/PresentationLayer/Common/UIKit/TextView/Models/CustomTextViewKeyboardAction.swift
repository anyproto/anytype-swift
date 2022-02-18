import UIKit
import AnytypeCore

extension CustomTextView {
    enum KeyboardAction {
        case enterAtTheBeginingOfContent
        case enterInsideContent(position: Int)
        case enterAtTheEndOfContent
        
        case deleteAtTheBeginingOfContent
        case deleteOnEmptyContent
    }
}

extension CustomTextView.KeyboardAction {
    private static let newLine = "\n"
    private static let emptyString = ""
    
    static func build(text: String, range: NSRange, replacement: String) -> Self? {
        guard let range = Range(range, in: text) else { return nil }

        let isEmpty = range.isEmpty && range.lowerBound == text.startIndex

        if replacement == newLine {
            if isEmpty {
                if text.isEmpty {
                    return .enterAtTheEndOfContent
                } else {
                    return .enterAtTheBeginingOfContent
                }
            }

            if text.endIndex == range.upperBound {
                return .enterAtTheEndOfContent
            }
            
            let position = String(text[..<range.lowerBound]).count
            return .enterInsideContent(position: position)
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
