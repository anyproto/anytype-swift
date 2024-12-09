import UIKit

extension UIScrollView {
    var topOffset: CGPoint {
        CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top)
    }
    
    var bottomOffset: CGPoint {
        return CGPoint(
            x: contentOffset.x,
            y: contentSize.height - bounds.height + adjustedContentInset.bottom
        )
    }
}
