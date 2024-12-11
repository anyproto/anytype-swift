import UIKit

extension UIScrollView {
    var topOffset: CGPoint {
        CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top)
    }
    
    var bottomOffset: CGPoint {
        if contentSize.height <= (bounds.height - adjustedContentInset.top - adjustedContentInset.bottom) {
            return topOffset
        }
        return CGPoint(
            x: contentOffset.x,
            y: contentSize.height - bounds.height + adjustedContentInset.bottom
        )
    }
}
