
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
}
