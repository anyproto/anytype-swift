import UIKit

final class DimmingTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        DimmingPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
