import UIKit

public extension UIViewController {
    var topPresentedController: UIViewController {
        guard var topPresentedController = presentedViewController,
                !topPresentedController.isBeingDismissed else {
            return self
        }
        
        while let presentedViewController = topPresentedController.presentedViewController,
                !presentedViewController.isBeingDismissed {
            topPresentedController = presentedViewController
        }
        return topPresentedController
    }
    
    var topVisibleController: UIViewController {
        let topController = topPresentedController
        if let navigationController = topController as? UINavigationController {
            return navigationController.topViewController ?? topController
        }
        return topController
    }
}
