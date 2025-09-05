import UIKit

extension UIView {
    func addTo(parent: UIView, frame: CGRect?) {
        if let frame {
            self.frame = frame
            if superview != parent {
                parent.addSubview(self)
            }
        } else if superview != nil {
            removeFromSuperview()
        }
    }
}
