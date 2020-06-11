//
//  MarksPane+ViewController+Presentation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: Presentation
extension MarksPane.ViewController {
    class func configured(_ controller: UIViewController) -> UIViewController {
//        controller.modalPresentationStyle = .custom
        let containerController = ContainerController.init()
        
        let presentation: TransitionController? = .init()
        let dismissal: TransitionController? = .init()
        _ = dismissal?.configured(transitionDirection: .backward)
        _ = presentation?.configured(presentedViewController: containerController)
        
        let resultController = containerController.configured(root: controller)
            .configured(presentationAnimator: presentation)
            .configured(presentationInteractor: presentation)
            .configured(dismissalAnimator: dismissal)
            .configured(dismissalInteractor: dismissal)
            .configured { (presented, presenting, source) in
                PresentationController.init(presentedViewController: presented, presenting: presenting)
            }
        
        resultController.modalPresentationStyle = .custom
        resultController.transitioningDelegate = resultController
        
        return resultController
    }
}

// MARK: - Presentation / ContainerController
extension MarksPane.ViewController {
    class ContainerController: UIViewController {
        private var rootViewController: UIViewController?
        private var presentationAnimator: UIViewControllerAnimatedTransitioning?
        private var dismissalAnimator: UIViewControllerAnimatedTransitioning?
        private var presentationInteractor: UIViewControllerInteractiveTransitioning?
        private var dismissalInteractor: UIViewControllerInteractiveTransitioning?
        private var presentationControllerBuilder: ((UIViewController, UIViewController?, UIViewController) -> UIPresentationController?)?
    }
}

// MARK: - Presentation / ContainerController / Life Cycle
extension MarksPane.ViewController.ContainerController {
    // MARK: - Setup
    func setupUIElements() {
        if let viewController = self.rootViewController {
            self.addChild(viewController)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
    }
    
    func addLayout() {
        if let view = self.rootViewController?.view, let superview = view.superview {
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
    }
}

// MARK: - Presentation / ContainerController / Configurations
extension MarksPane.ViewController.ContainerController {
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

extension MarksPane.ViewController.ContainerController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presentationAnimator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        (self.dismissalAnimator as? MarksPane.ViewController.TransitionController)?.configured(presentedViewController: dismissed)
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

// MARK: - Presentation / Presentation Controller
extension MarksPane.ViewController {
    class PresentationController: UIPresentationController {
        var backgroundView: UIView?
        func createView() -> UIView {
            let view: UIView = .init()
            view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
        
        // MARK: - Setup
        private func setupUIElements() {
            let view = self.createView()
            let containerView = self.containerView
            containerView?.addSubview(view)
            
            if let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            self.backgroundView = view
        }
        
        // MARK: - Presentation Controller / Subclassing / Sizes
        override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
            // Take data from KeyboardSize (?)
            .init(width: parentSize.width, height: parentSize.height * 1/3.0)
        }
        
        override var frameOfPresentedViewInContainerView: CGRect {
            guard let containerView = self.containerView else {
                return .zero
            }
            
            let size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerView.frame.size)
            let origin: CGPoint = .init(x: 0, y: containerView.frame.size.height - size.height)
            return .init(origin: origin, size: size)
        }
        
        override var shouldRemovePresentersView: Bool {
            return false
        }
        
        // MARK: - Presentation Controller / Subclassing / Layout
        override func containerViewWillLayoutSubviews() {
            super.containerViewWillLayoutSubviews()
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
        
        // MARK: - Presentation Controller / Subclassing / Animation
        override func presentationTransitionWillBegin() {
            self.setupUIElements()
            
            self.presentingViewController.beginAppearanceTransition(false, animated: false)
            
            let fromAlpha: CGFloat = 0.0
            let toAlpha: CGFloat = 1.0
            
            self.backgroundView?.alpha = fromAlpha
            self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (value) in
                self?.backgroundView?.alpha = toAlpha
            }, completion: { (value) in })
        }
        
        override func presentationTransitionDidEnd(_ completed: Bool) {
            self.presentingViewController.endAppearanceTransition()
        }
        
        override func dismissalTransitionWillBegin() {
            self.presentingViewController.beginAppearanceTransition(true, animated: true)
            
            let fromAlpha: CGFloat = 1.0
            let toAlpha: CGFloat = 0.0
            
            self.backgroundView?.alpha = fromAlpha
            self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (value) in
                self?.backgroundView?.alpha = toAlpha
            }, completion: { (value) in })
        }
        
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            self.presentingViewController.endAppearanceTransition()
            if completed {
                self.backgroundView?.removeFromSuperview()
            }
        }
    }
}

// MARK: - Transition Controller
extension MarksPane.ViewController {
    class TransitionController: NSObject {
        private var transitionDriver: TransitionDriver?        
        private var transitionAnimator: UIViewPropertyAnimator?
        private var transitionDuration: TimeInterval = 0.6
        private var initiallyInteractive: Bool = false
        private var transitionDirection: TransitionDriver.Direction?
        
        private var gestureRecognizer: TransitionDriver.TransitionGestureRecognizer = .init()
        private weak var presentedViewController: UIViewController?
        
        private var isInteractive: Bool {
            self.initiallyInteractive
        }
        
        override init() {
            super.init()
            self.configure(gestureRecognizer: self.gestureRecognizer)
        }
        
        // MARK: - Setup
        private func configure(gestureRecognizer: TransitionDriver.TransitionGestureRecognizer) {
            gestureRecognizer.delegate = self
            gestureRecognizer.maximumNumberOfTouches = 1
            gestureRecognizer.addTarget(self, action: #selector(initiateTransitionInteractively(_:)))
        }
        
        // MARK: - Start Interaction
        @objc func initiateTransitionInteractively(_ panGesture: UIPanGestureRecognizer) {
            if panGesture.state == .began && transitionDriver == nil {
                self.initiallyInteractive = true
//                if let context = self.transitionContext, let toViewController = context.viewController(forKey: .to), toViewController.presentingViewController != nil {
//                    toViewController.dismiss(animated: true, completion: nil)
//                    self.transitionContext = nil
//                }
                if let controller = self.presentedViewController {
                    self.gestureRecognizer.removeTarget(self, action: nil)
                    controller.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - Transition Controller / UIGestureRecognizerDelegate
extension MarksPane.ViewController.TransitionController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let transitionDriver = self.transitionDriver else {
            if let panGestureRecognizer = gestureRecognizer as? TransitionDriver.TransitionGestureRecognizer {
                let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
                let translationIsVertical = (translation.y > 0) && (abs(translation.y) > abs(translation.x))
                return translationIsVertical
            }
            return false
        }
        
        return transitionDriver.isInteractive
    }
}

// MARK: - Transition Controller / Configurations
extension MarksPane.ViewController.TransitionController {
    private func configured(transitionDriver: TransitionDriver?) -> Self {
        self.transitionDriver = transitionDriver
        return self
    }
    func configured(transitionDuration: TimeInterval) -> Self {
        self.transitionDuration = transitionDuration
        return self
    }
    func configured(initiallyInteractive: Bool) -> Self {
        self.initiallyInteractive = initiallyInteractive
        return self
    }
    func configured(transitionDirection: TransitionDriver.Direction?) -> Self {
        self.transitionDirection = transitionDirection
        return self
    }
    func configured(transitionAnimator: UIViewPropertyAnimator?) -> Self {
        self.transitionAnimator = transitionAnimator
        return self
    }
    func configured(presentedViewController: UIViewController?) -> Self {
        self.presentedViewController = presentedViewController
        return self
    }
}

// MARK: - Transition Controller / UIViewControllerAnimatedTransitioning
extension MarksPane.ViewController.TransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
    
    func animationEnded(_ transitionCompleted: Bool) {
        self.initiallyInteractive = false
        self.transitionDriver = nil
    }
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        self.transitionDriver?.transitionAnimator ?? UIViewPropertyAnimator.init()
    }
}

// MARK: - Transition Controller / UIViewControllerInteractiveTransitioning
extension MarksPane.ViewController.TransitionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        Debug.debug(transitionContext)
        self.transitionDriver = .init(context: transitionContext, gestureRecognizer: self.gestureRecognizer, transitionAnimator: self.transitionAnimator)
        if let direction = self.transitionDirection {
            _ = self.transitionDriver?.configured(direction: direction)
        }
        _ = self.transitionDriver?.configured()
    }

    var wantsInteractiveStart: Bool {
        self.isInteractive
    }
}

// Debug
extension MarksPane.ViewController.TransitionController {
    enum Debug {
        static func debug(_ value: UIViewControllerContextTransitioning) {
            let context = value
            let fromViewController = context.viewController(forKey: .from)!
            let toViewController = context.viewController(forKey: .to)!
            let fromView = fromViewController.view!
            let toView = toViewController.view!
            let containerView = context.containerView
            
            let fromInitialFrame = context.initialFrame(for: fromViewController)
            let fromFinalFrame = context.finalFrame(for: fromViewController)
            let toInitialFrame = context.initialFrame(for: toViewController)
            let toFinalFrame = context.finalFrame(for: toViewController)

            let string: String = """
            -----------------------------------------------
            
            context: \(String.init(describing: context)) \n
            fromViewController: \(String.init(describing: fromViewController)) \n
            toViewController: \(String.init(describing: toViewController)) \n
            fromView: \(String.init(describing: fromView)) \n
            toView: \(String.init(describing: toView)) \n
            containerView: \(String.init(describing: containerView)) \n
            
            fromInitialFrame: \(String.init(describing: fromInitialFrame)) \n
            toInitialFrame: \(String.init(describing: toInitialFrame)) \n
            fromFinalFrame: \(String.init(describing: fromFinalFrame)) \n
            toFinalFrame: \(String.init(describing: toFinalFrame)) \n
            
            -----------------------------------------------
            """
            
            print(string)
        }
    }
}
