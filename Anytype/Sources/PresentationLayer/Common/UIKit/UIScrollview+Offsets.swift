import UIKit

extension UIScrollView {
    var topOffset: CGPoint {
        CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top)
    }
}
