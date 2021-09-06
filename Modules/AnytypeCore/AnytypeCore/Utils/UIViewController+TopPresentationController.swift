import UIKit

public extension UIViewController {
    var topPresentedController: UIViewController {
        guard var topPresentedController = presentedViewController else {
            return self
        }
        
        while let presentedViewController = topPresentedController.presentedViewController {
            topPresentedController = presentedViewController
        }
        return topPresentedController
    }
}
