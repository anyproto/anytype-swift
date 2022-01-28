import UIKit

// https://www.swiftbysundell.com/basics/child-view-controllers/
extension UIViewController {
    /// Sugar for adding view controller as a child
    /// - Parameter vc: view controller to add
    func embedChild(_ vc: UIViewController, into container: UIView? = nil) {
        vc.willMove(toParent: self)
        addChild(vc)
        if let container = container {
            container.addSubview(vc.view)
        } else {
            view.addSubview(vc.view)
        }
        vc.didMove(toParent: self)
    }
    
    /// Sugar for removing view controller from parent
    func removeFromParentEmbed() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

