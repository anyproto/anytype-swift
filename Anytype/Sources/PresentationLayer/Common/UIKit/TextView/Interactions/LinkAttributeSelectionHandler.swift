import UIKit

struct LinkAttributeSelectionHandler: TextViewAttributeSelectionHandler {
    
    func didSelect(
        _ attribute: NSAttributedString.Key,
        in textView: UITextView,
        recognizer: UITapGestureRecognizer
    ) {
        let tapLocation = recognizer.location(in: textView)
        guard let position = textView.closestPosition(to: tapLocation) else { return }
        
        textView.select(recognizer)
        let range = textView.tokenizer.rangeEnclosingPosition(
            position,
            with: .word,
            inDirection: .storage(.forward)
        )
        textView.selectedTextRange = range
    }
}


