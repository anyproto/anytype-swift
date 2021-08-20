import UIKit

protocol TextViewAttributeSelectionHandler {
    
    func didSelect(
        _ attribute: NSAttributedString.Key,
        in textView: UITextView,
        recognizer: UITapGestureRecognizer
    )
}
