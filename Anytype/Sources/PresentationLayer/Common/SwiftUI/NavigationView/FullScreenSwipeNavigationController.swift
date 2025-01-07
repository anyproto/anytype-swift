import UIKit

final class FullScreenSwipeNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupFullScreenSwipe()
    }
    
    func setupFullScreenSwipe() {
        guard let target = interactivePopGestureRecognizer?.delegate else { return }
        
        let selector = NSSelectorFromString("handleNavigationTransition:")
        if target.responds(to: selector) {
            let panGestureRecognizer = UIPanGestureRecognizer(
                target: target,
                action: selector
            )
            panGestureRecognizer.delegate = self
            self.view.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard viewControllers.count > 1 else { return false }
        
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        return translation.x > 0
    }
}
