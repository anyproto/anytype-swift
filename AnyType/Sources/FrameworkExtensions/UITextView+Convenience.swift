
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
        return .at(selectedRange)
    }
}
