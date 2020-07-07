//
//  CommonViews+ViewControllers+TransitionContainer.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

fileprivate typealias Namespace = CommonViews.ViewControllers
fileprivate typealias FileNamespace = Namespace.TransitionContainerViewController

extension Namespace {
    class TransitionContainerViewController: UIViewController {
        private var rootViewController: UIViewController?
        private var presentationAnimator: UIViewControllerAnimatedTransitioning?
        private var dismissalAnimator: UIViewControllerAnimatedTransitioning?
        private var presentationInteractor: UIViewControllerInteractiveTransitioning?
        private var dismissalInteractor: UIViewControllerInteractiveTransitioning?
        private var presentationControllerBuilder: ((UIViewController, UIViewController?, UIViewController) -> UIPresentationController?)?
    }
}

// MARK: - Setup
extension FileNamespace {
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
}

// MARK: - View Lifecycle
extension FileNamespace {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
    }
}

// MARK: - Configurations
extension FileNamespace {
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
extension Namespace.TransitionContainerViewController: UIViewControllerTransitioningDelegate {
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
