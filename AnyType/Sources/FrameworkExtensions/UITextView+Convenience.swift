
import BlocksModels
import UIKit

extension UITextView {
    
    /// Append plain string to attributed string.
    /// If attributedText is empty, `typingAttributes` will be set to default.
    /// This method avoids this undesired behavior and set `typingAttributes` properly.
    ///
    /// - Parameters:
    ///   - string: String to append
    func appendStringToAttributedString(_ string: String) {
        guard !string.isEmpty else { return }
        if attributedText.length == 0 {
            attributedText = NSAttributedString(string: string, attributes: typingAttributes)
        } else {
            attributedText = attributedText?.attributedStringByAppending(string)
        }
    }
    
    func caretPosition() -> UITextPosition? {
        if !isFirstResponder {
            return nil
        }
        let offset = selectedRange.location + selectedRange.length
        return position(from: beginningOfDocument, offset: offset)
    }
    
    func setFocus(_ position: BlockFocusPosition) {
        switch position {
        case .unknown:
            return
        case .beginning:
            selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
        case .end:
            selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
        case let .at(value):
            let length = textStorage.length
            let newValue = min(max(value, 0), length)
            switch newValue {
            case 0: setFocus(.beginning)
            case length: setFocus(.end)
            default:
                if let textPosition = self.position(from: beginningOfDocument, offset: newValue) {
                    let range = textRange(from: textPosition, to: textPosition)
                    selectedTextRange = range
                }
            }
        }
        if !isFirstResponder && canBecomeFirstResponder {
            becomeFirstResponder()
        }
    }
}
