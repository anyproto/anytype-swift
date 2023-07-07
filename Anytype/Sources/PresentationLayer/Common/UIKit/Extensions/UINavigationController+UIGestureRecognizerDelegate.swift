import UIKit

final class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    var disableBackSwipe = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return disableBackSwipe ? false : viewControllers.count > 1
    }
}
