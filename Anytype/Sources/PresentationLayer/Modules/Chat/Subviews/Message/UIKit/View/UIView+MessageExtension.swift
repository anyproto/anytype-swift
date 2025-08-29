import UIKit

extension UIView {
    func addTo(parent: UIView, frame: CGRect?) {
        if let frame {
            self.frame = frame
            parent.addSubview(self)
        } else {
            removeFromSuperview()
        }
    }
}
