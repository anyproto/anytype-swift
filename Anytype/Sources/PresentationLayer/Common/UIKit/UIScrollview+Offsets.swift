import UIKit

extension UIScrollView {
    var topOffset: CGPoint {
        CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top)
    }
    
    var bottomOffset: CGPoint {
        if contentSize.height <= visibleHeight {
            return topOffset
        }
        return CGPoint(
            x: contentOffset.x,
            y: contentSize.height - bounds.height + adjustedContentInset.bottom
        )
    }
    
    var visibleHeight: CGFloat {
        bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
    }
    
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion?()
            }
            setContentOffset(contentOffset, animated: animated)
            CATransaction.commit()
        } else {
            setContentOffset(contentOffset, animated: animated)
            completion?()
        }
    }
}
