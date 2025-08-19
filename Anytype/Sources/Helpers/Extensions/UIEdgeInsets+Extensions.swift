import UIKit

extension UIEdgeInsets {
    
    var inverted: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -left)
    }
}
