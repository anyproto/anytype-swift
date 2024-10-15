import UIKit

struct MentionAttributeSelectionHandler {
    
    private let showObject: (String) -> Void
    
    init(showObject: @escaping (String) -> Void) {
        self.showObject = showObject
    }
}

extension MentionAttributeSelectionHandler: TextViewAttributeSelectionHandler {
    
    func didSelect(
        _ attribute: NSAttributedString.Key,
        in textView: UITextView,
        recognizer: UITapGestureRecognizer
    ) {
        let tapLocation = recognizer.location(in: textView)
        
        guard let position = textView.closestPosition(to: tapLocation) else {
            return
        }
        let characterIndex = textView.offset(
            from: textView.beginningOfDocument,
            to: position
        )
        
        if textView.isFirstResponder {
            textView.selectedRange = .init(location: characterIndex, length: 0)
            return
        }
        
        guard let objectId: String = textView.attributedText.value(
                for: attribute,
                range: NSRange(location: characterIndex, length: 1)
        ) else {
            textView.selectedRange = .init(location: characterIndex, length: 0)
            textView.becomeFirstResponder()
            return
        }
        showObject(objectId)
    }
}
