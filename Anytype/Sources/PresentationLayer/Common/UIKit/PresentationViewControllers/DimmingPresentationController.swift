//
//  DimmingPresentationController.swift
//  AnyType
//
//  Created by Kovalev Alexander on 06.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

/// Presentaion controller for dimmig background
final class DimmingPresentationController: UIPresentationController {
    
    private enum Constants {
        static let finalAlpha: CGFloat = 0.3
    }
    
    private var dimmingView: UIView?
    
    override func presentationTransitionWillBegin() {
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = .strokePrimary
        dimmingView.alpha = 0
        self.dimmingView = dimmingView
        containerView?.addSubview(dimmingView)
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = Constants.finalAlpha
        }, completion: {(context) in
            if context.isCancelled {
                dimmingView.removeFromSuperview()
            }
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let dimmingView = self.dimmingView else {return}
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 0
        }, completion: {(context) in
            if !context.isCancelled {
                dimmingView.removeFromSuperview()
            }
        })
    }
}
