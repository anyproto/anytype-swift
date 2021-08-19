import AnytypeCore
import UIKit

/// Entity to select text with .link attribute by double tap
final class TextViewLinkSelectorInteraction: NSObject {
    
    private weak var textView: UITextView?
    
    init(textView: UITextView) {
        self.textView = textView
    }
    
    private func linkRects() -> [CGRect]? {
        guard let textView = textView,
              let linkRanges = textView.attributedText.rangesWith(attribute: .link) else {
            return nil
        }
        let glyphRanges = linkRanges.map { range in
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
        let tapLocation = gestureRecognizer.location(in: textView)
        
        guard let position = textView?.closestPosition(to: tapLocation) else { return }
        
        textView?.select(gestureRecognizer)
        let range = textView?.tokenizer.rangeEnclosingPosition(
            position,
            with: .word,
            inDirection: .storage(.forward)
        )
        textView?.selectedTextRange = range
    }
    
}

extension TextViewLinkSelectorInteraction: UIInteraction {

    var view: UIView? {
        textView
    }
    
    func willMove(to view: UIView?) {}
    
    func didMove(to view: UIView?) {
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handle)
        )
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.delegate = self
        view?.addGestureRecognizer(gestureRecognizer)
    }
}

extension TextViewLinkSelectorInteraction: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let linkRects = linkRects() else {
            return false
        }
        let tapLocation = gestureRecognizer.location(in: textView)
        return linkRects.contains { rect in
            rect.contains(tapLocation)
        }
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
