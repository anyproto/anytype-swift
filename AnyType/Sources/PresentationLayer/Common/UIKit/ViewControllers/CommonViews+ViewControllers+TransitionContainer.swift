import Foundation
import UIKit


extension CommonViews.ViewControllers {
    class TransitionContainerViewController: UIViewController {
        private var rootViewController: UIViewController?
        private var presentationAnimator: UIViewControllerAnimatedTransitioning?
        private var dismissalAnimator: UIViewControllerAnimatedTransitioning?
        private var presentationInteractor: UIViewControllerInteractiveTransitioning?
        private var dismissalInteractor: UIViewControllerInteractiveTransitioning?
        private var presentationControllerBuilder: ((UIViewController, UIViewController?, UIViewController) -> UIPresentationController?)?
    }
}


// MARK: - View Lifecycle
extension CommonViews.ViewControllers.TransitionContainerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        rootViewController.flatMap { embedChild($0) }
        rootViewController?.view.pinAllEdges(to: view)
    }
}

// MARK: - Configurations
extension CommonViews.ViewControllers.TransitionContainerViewController {
    func configured(root rootViewController: UIViewController) -> Self {
        self.rootViewController = rootViewController
        return self
    }
    func configured(presentationAnimator: UIViewControllerAnimatedTransitioning?) -> Self {
        self.presentationAnimator = presentationAnimator
        return self
    }
    func configured(dismissalAnimator: UIViewControllerAnimatedTransitioning?) -> Self {
        self.dismissalAnimator = dismissalAnimator
        return self
    }
    func configured(presentationInteractor: UIViewControllerInteractiveTransitioning?) -> Self {
        self.presentationInteractor = presentationInteractor
        return self
    }
    func configured(dismissalInteractor: UIViewControllerInteractiveTransitioning?) -> Self {
        self.dismissalInteractor = dismissalInteractor
        return self
    }
    func configured(presentationControllerBuilder: ((UIViewController, UIViewController?, UIViewController) -> UIPresentationController?)?) -> Self {
        self.presentationControllerBuilder = presentationControllerBuilder
        return self
    }
}

// MARK: - Delegates / UIViewControllerTransitioningDelegate
extension CommonViews.ViewControllers.TransitionContainerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presentationAnimator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        nil
    }
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.presentationInteractor
    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.dismissalInteractor
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self.presentationControllerBuilder?(presented, presenting, source)
    }
}
