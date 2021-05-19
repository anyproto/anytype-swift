
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
        case .beginning:
            selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
        case .end:
            selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
        case let .at(value):
            let length = textStorage.length
            let newValue = min(max(value, 0), length)
            // New value is an actual desired caret position in UITextView
            // so 0 means begininng of document
            // length means end of document, example:
            // "some text" (lenght 9) .at(9) the same as .end
            // default means caret should be placed somewhere at the middle of document
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
    
    func textChangeType(changeTextRange: NSRange, replacementText: String) -> TextViewTextChangeType {
        if replacementText == "",  changeTextRange.location < text.count {
            return .deletingSymbols
        }
        return .typingSymbols
    }
}

extension UITextView: TextViewManagingFocus, TextViewUpdatable {
    func apply(update: TextViewUpdate) {
        switch update {
        case let .text(value):
            guard value != textStorage.string else { return }

            if textStorage.length == 0 {
                let text = NSAttributedString(string: value, attributes: typingAttributes)
                textStorage.setAttributedString(text)
            } else {
                textStorage.replaceCharacters(in: .init(location: 0, length: textStorage.length), with: value)
            }
        case let .attributedText(value):
            let text = NSMutableAttributedString(attributedString: value)

            guard text != textStorage else { return }

            textStorage.setAttributedString(text)
        case let .auxiliary(value):
            self.backgroundColor = value.blockColor
            self.textAlignment = value.textAlignment
        case let .payload(value):
            self.apply(update: .attributedText(value.attributedString))
            self.apply(update: .auxiliary(value.auxiliary))
        }
    }

    func shouldResignFirstResponder() {
        resignFirstResponder()
    }

    func setFocus(_ focus: TextViewFocus?) {
        guard let position = focus?.position else { return }
        setFocus(position)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard isFirstResponder else { return nil }

        let caretLocation = selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(caretLocation)
    }

}
