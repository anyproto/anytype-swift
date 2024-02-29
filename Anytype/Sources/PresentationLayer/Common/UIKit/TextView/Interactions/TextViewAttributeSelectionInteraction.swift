import UIKit

final class TextViewAttributeSelectionInteraction: NSObject {
    
    private weak var textView: UITextView?
    private let attributeKey: NSAttributedString.Key
    private let numberOfTapsRequired: Int
    private let tapHandler: TextViewAttributeSelectionHandler
    
    init(
        textView: UITextView,
        attributeKey: NSAttributedString.Key,
        numberOfTapsRequired: Int,
        tapHandler: TextViewAttributeSelectionHandler
    ) {
        self.textView = textView
        self.attributeKey = attributeKey
        self.numberOfTapsRequired = numberOfTapsRequired
        self.tapHandler = tapHandler
    }
    
    private func attributeRectsForTap() -> [CGRect]? {
        guard let textView = textView,
              let ranges = textView.attributedText.rangesWith(attribute: attributeKey) else {
            return nil
        }
        let glyphRanges = ranges.map { range in
            textView.layoutManager.glyphRange(
                forCharacterRange: range,
                actualCharacterRange: nil
            )
        }
        let boundingRects = glyphRanges.map { range -> CGRect in
            textView.layoutManager.boundingRect(
                forGlyphRange: range,
                in: textView.textContainer
            )
        }
        let containerInset = textView.textContainerInset
        let additionalHeight = (containerInset.top + containerInset.bottom) / 2
        return boundingRects.map { rect in
            CGRect(
                origin: rect.origin,
                size: CGSize(
                    width: rect.width,
                    height: rect.height + additionalHeight
                )
            )
        }
    }
    
    @objc private func handle(gestureRecognizer: UITapGestureRecognizer) {
        guard let textView = textView else { return }
        tapHandler.didSelect(
            attributeKey,
            in: textView,
            recognizer: gestureRecognizer
        )
    }
}

extension TextViewAttributeSelectionInteraction: UIInteraction {

    var view: UIView? {
        textView
    }
    
    func willMove(to view: UIView?) {}
    
    func didMove(to view: UIView?) {
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handle)
        )
        gestureRecognizer.numberOfTapsRequired = numberOfTapsRequired
        gestureRecognizer.delegate = self
        view?.addGestureRecognizer(gestureRecognizer)
    }
}

extension TextViewAttributeSelectionInteraction: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let rects = attributeRectsForTap() else {
            return false
        }
        let tapLocation = gestureRecognizer.location(in: textView)
        return rects.contains { rect in rect.contains(tapLocation) }
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}

