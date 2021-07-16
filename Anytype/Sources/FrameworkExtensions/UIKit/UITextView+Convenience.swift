
import BlocksModels
import UIKit

extension UITextView {
    
    /// Append plain string to attributed string.
    /// If attributedText is empty, `typingAttributes` will be set to default.
    /// This method avoids this undesired behavior and set `typingAttributes` properly.
    ///
    /// - Parameters:
    ///   - string: String to insert
    func insertStringToAttributedString(_ string: String) {
        guard !string.isEmpty else { return }
        if attributedText.length == 0 {
            attributedText = NSAttributedString(string: string, attributes: typingAttributes)
        } else {
            let selectedRangeLocation = selectedRange.location
            attributedText = attributedText?.attributedStringByInserting(
                string,
                at: selectedRangeLocation,
                attachmentAttributes: typingAttributes
            )
            selectedRange.location = selectedRangeLocation + string.count
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
        let selectedRange = position.toSelectedRange(in: text)

        if let beginningSelectedTextPostion = self.position(from: beginningOfDocument, offset: selectedRange.location),
           let endSelectedTextPosition = self.position(from: beginningSelectedTextPostion, offset: selectedRange.length)
        {
            selectedTextRange = textRange(from: beginningSelectedTextPostion, to: endSelectedTextPosition)
        } else {
            selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
        }

        if !isFirstResponder && canBecomeFirstResponder {
            becomeFirstResponder()
        }
    }
    
    func textChangeType(changeTextRange: NSRange, replacementText: String) -> TextViewTextChangeType {
        if replacementText == "",  changeTextRange.location < text.count {
            return .deletingSymbols
        }
        return .typingSymbols
    }
}

extension UITextView: TextViewManagingFocus {
    func shouldResignFirstResponder() {
        resignFirstResponder()
    }

    func setFocus(_ focus: BlockFocusPosition?) {
        guard let focus = focus else { return }
        setFocus(focus)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard isFirstResponder else { return nil }
        return .at(selectedRange)
    }
}
