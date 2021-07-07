import Foundation
import UIKit


// MARK: UserActions
extension CustomTextView {
    
    public enum UserAction {
        case showStyleMenu
        
        case changeText(UITextView)
        case changeTextForStruct(UITextView)
        case changeTextStyle(CustomTextView.ContextMenuAction, NSRange)
        
        case keyboardAction(KeyboardAction)
        case showMultiActionMenuAction
        case changeCaretPosition(NSRange)
        case shouldChangeText(range: NSRange, replacementText: String, mentionsHolder: Mentionable)
    }    
}

// MARK: - KeyboardAction
extension CustomTextView.UserAction {
    // Actions with input custom keys
    enum KeyboardAction {
        /// press enter when content is empty (length == 0)
        case enterOnEmptyContent(String?)
        /// press enter when cursor inside the content (content not empty and cursor not at the end)
        case enterInsideContent(String?, String?)
        /// press enter  when cursor at the end of the content
        case enterAtTheEndOfContent
        /// press delete with content (length > 0)
        case deleteWithPayload(String?)
        /// press delete when content is empty (length == 0)
        case deleteOnEmptyContent

        static func convert(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Self? {
            // We should also keep values to the right of the Cursor.
            // So, enter key should have minimum one value as String on the right as Optional<String>
            
            switch (textView.text, range, text) {
            // Easy - our range is equal to .zero and we press "\n" -> we press enter at beginning.
            case (_, .init(location: 0, length: 0), "\n"): return .enterOnEmptyContent(textView.text)

            // Next - our text?.count == at.location + at.length and we press enter.
            // Press enter at the end.
            case let (text, at, "\n") where text?.count == at.location + at.length: return .enterAtTheEndOfContent

            // Somewhere in the middle of text
            case let (text, at, "\n"):
                guard let text = text else { return nil }
                // split text on two part - top and bottom text
                let topString = text.prefix(at.location)
                let bottomStringStart = text.index(text.startIndex, offsetBy: at.location + at.length)
                let bottomString = text[bottomStringStart..<text.endIndex]
                return .enterInsideContent(String(topString), String(bottomString))

            // Text is empty and range is equal .zero and we press backspace.
            // That means, that our string is empty and we press delete on textView with empty text.
            case ("", .init(location: 0,length: 0), ""): return .deleteOnEmptyContent

            // Next - our text is _not_ empty and range is equal .zero and we press backspace.
            // That means, that our string is not empty and we press delete at the beginning of the string of text view.
            case let (text, .init(location: 0, length: 0), ""): return .deleteWithPayload(text)
            default: return nil
            }
        }
    }
}
