import Foundation
import UIKit

@MainActor
final class ResponderScrollViewHelper {

    @Injected(\.keyboardHeightListener)
    private var keyboardListener: KeyboardHeightListener
    private weak var scrollView: UIScrollView?

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    func scrollBlockToVisibleArea(textView: UITextView) {
        guard let window = textView.window else {
            return
        }

        guard let position = textView.selectedTextRange?.end else { return }
        let cursorPosition = textView.caretRect(for: position)

        let cursorViewFrame = textView.convert(cursorPosition, to: window)
        
        if cursorViewFrame.origin.y < Constants.minSpacingBelowTopAnchor {
            
            let offset = abs(cursorViewFrame.origin.y - Constants.minSpacingBelowTopAnchor)
            
            performContentOffsetChange(yDelta: -offset)
            return
        }
        
        if keyboardListener.currentKeyboardFrame == .zero {
            // Check for attached keyboard scenarios
        } else {
            let distance = cursorViewFrame.maxY - keyboardListener.currentKeyboardFrame.minY
        
            if distance > -Constants.minSpacingAboveKeyboard {
                performContentOffsetChange(yDelta: distance + Constants.minSpacingAboveKeyboard)
            }
        }
    }
    
    private func performContentOffsetChange(yDelta: CGFloat) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak scrollView] in
            guard let scrollView else  { return }
            var contentOffset = scrollView.contentOffset
            contentOffset.y = contentOffset.y + yDelta
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
}

extension ResponderScrollViewHelper {
    private enum Constants {
        static let minSpacingAboveKeyboard: CGFloat = 30
        static let minSpacingBelowTopAnchor: CGFloat = 44 + 60
    }
}
