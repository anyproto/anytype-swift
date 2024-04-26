import UIKit

struct MentionAttributeSelectionHandler {
    
    private let showPage: (String) -> Void
    
    init(showPage: @escaping (String) -> Void) {
        self.showPage = showPage
    }
}

extension MentionAttributeSelectionHandler: TextViewAttributeSelectionHandler {
    
    func didSelect(
        _ attribute: NSAttributedString.Key,
        in textView: UITextView,
        recognizer: UITapGestureRecognizer
    ) {
        let tapLocation = recognizer.location(in: textView)
        guard !textView.isFirstResponder,
              let position = textView.closestPosition(to: tapLocation) else {
            return
        }
        let characterIndex = textView.offset(
            from: textView.beginningOfDocument,
            to: position
        )
        guard let pageId: String = textView.attributedText.value(
                for: attribute,
                range: NSRange(location: characterIndex, length: 1)
        ) else {
            return
        }
        showPage(pageId)
    }
}
