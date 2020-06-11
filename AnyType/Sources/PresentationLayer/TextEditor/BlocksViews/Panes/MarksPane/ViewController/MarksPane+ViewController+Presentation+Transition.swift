//
//  MarksPane+ViewController+Presentation+Transition.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Transition Driver
extension MarksPane.ViewController.TransitionController {
    class TransitionDriver: NSObject {
        typealias TransitionGestureRecognizer = UIPanGestureRecognizer
        
        var isInteractive: Bool { self.transitionContext.isInteractive }
        
        var transitionContext: UIViewControllerContextTransitioning
        var gestureRecognizer: TransitionGestureRecognizer
        var transitionAnimator: UIViewPropertyAnimator
        var direction: Direction = .default
        
        internal init(context: UIViewControllerContextTransitioning, gestureRecognizer: TransitionGestureRecognizer, transitionAnimator: UIViewPropertyAnimator? = nil) {
            self.transitionContext = context
            self.gestureRecognizer = gestureRecognizer
            self.transitionAnimator = transitionAnimator ?? AnimatorBuilder.create()// create default animator

            super.init()
        }
        
        var isForward: Bool { self.direction == .forward }
        
        // And now update
    }
}

// MARK: - Transition Driver / Configurations
extension MarksPane.ViewController.TransitionController.TransitionDriver {
    func configured(direction: Direction) -> Self {
        self.direction = direction
        return self
    }
}

// MARK: - Transition Driver / Direction
extension MarksPane.ViewController.TransitionController.TransitionDriver {
    enum Direction {
        case forward, backward
        static let `default`: Self = .forward
    }
}

extension MarksPane.ViewController.TransitionController.TransitionDriver {
    func configured() -> Self {
        self.setup()
        return self
    }
}

// MARK: - Transition Driver / Setup
private extension MarksPane.ViewController.TransitionController.TransitionDriver {
    func setup() {
        let context = self.transitionContext
        let fromViewController = context.viewController(forKey: .from)!
        let toViewController = context.viewController(forKey: .to)!
        let fromView = fromViewController.view!
        let toView = toViewController.view!
        let containerView = context.containerView
        
        // Setup gesture recognizer to receive updates.
        self.gestureRecognizer.addTarget(self, action: #selector(updateInteractionFromGesture(_:)))
                
        let isBackward = !self.isForward
                
        containerView.addGestureRecognizer(self.gestureRecognizer)

        let animatedView: UIView = isBackward ? fromView : toView
        containerView.addSubview(animatedView)
        
        let initialTransform: CGAffineTransform = isBackward ? .identity : .init(translationX: 0, y: containerView.frame.size.height)
        let finalTransform: CGAffineTransform = isBackward ? .init(translationX: 0, y: containerView.frame.size.height) : .identity
                
        let initialAlpha: CGFloat = isBackward ? 1.0 : 0.0
        let finalAlpha: CGFloat = isBackward ? 0.0 : 1.0
        
        animatedView.alpha = initialAlpha
        animatedView.transform = initialTransform
        
        self.setupTransitionAnimator({
            animatedView.alpha = finalAlpha
            animatedView.transform = finalTransform
        }, transitionCompletion: { _ in
        })
        
        if context.isInteractive {
//            animate(.end)
        } else {
            // Begin the animation phase immediately if the transition is not initially interactive
            animate(.end)
        }
    }
}

// MARK: - Transition Driver / Completion Position
private extension MarksPane.ViewController.TransitionController.TransitionDriver {
    enum CompletionPositionConverter {
        private struct Vector {
            var vector: CGVector
            init(_ point: CGPoint) {
                self.vector = .init(dx: point.x, dy: point.y)
            }
            func magnitude() -> CGFloat {
                sqrt(self.vector.dx * self.vector.dx + self.vector.dy * self.vector.dy)
            }
        }
        
        static func progressStepFor(isForward: Bool, translation: CGPoint, containerView: UIView) -> CGFloat {
            return (isForward ? -1.0 : 1.0) * translation.y / containerView.bounds.midY
        }
        
        static func completionPosition(isForward: Bool, containerView: UIView, gestureRecognizer: TransitionGestureRecognizer, animatorProgress: CGFloat) -> UIViewAnimatingPosition {
            let completionThreshold: CGFloat = 0.33
            let flickMagnitude: CGFloat = 1200 //pts/sec
            let velocity: Vector = .init(gestureRecognizer.velocity(in: containerView))
            let isFlick = (velocity.magnitude() > flickMagnitude)
            let isFlickDown = isFlick && (velocity.vector.dy > 0.0)
            let isFlickUp = isFlick && (velocity.vector.dy < 0.0)
            if (isForward && isFlickUp) || (!isForward && isFlickDown) {
                return .end
            } else if (isForward && isFlickDown) || (!isForward && isFlickUp) {
                return .start
            } else if animatorProgress > completionThreshold {
                return .end
            } else {
                return .start
            }
        }
    }
}

// MARK: - Transition Driver / Animator Builder
private extension MarksPane.ViewController.TransitionController.TransitionDriver {
    enum AnimatorBuilder {
        static func duration() -> TimeInterval { 0.3 }
        static func create() -> UIViewPropertyAnimator { .init(duration: self.duration(), curve: .easeInOut) }
    }
}

// MARK: - Transition Driver / Setup Animator
private extension MarksPane.ViewController.TransitionController.TransitionDriver {
    func setupTransitionAnimator(_ transitionAnimations: @escaping ()->(), transitionCompletion: @escaping (UIViewAnimatingPosition)->()) {
                
        // Create a UIViewPropertyAnimator that lives the lifetime of the transition
        self.transitionAnimator.addAnimations(transitionAnimations)
        
        self.transitionAnimator.addCompletion { [unowned self] (position) in
            // Call the supplied completion
            transitionCompletion(position)
            
            // Inform the transition context that the transition has completed
            let completed = (position == .end)
            self.transitionContext.completeTransition(completed)
        }
    }
}

// MARK: - Transition Driver / Interaction Manipulation
private extension MarksPane.ViewController.TransitionController.TransitionDriver {
    @objc func updateInteractionFromGesture(_ fromGesture: UIPanGestureRecognizer) {
        self.updateInteraction(fromGesture)
    }
    func updateInteraction(_ fromGesture: UIPanGestureRecognizer) {
        switch fromGesture.state {
            case .began, .changed:
                // Ask the gesture recognizer for it's translation
                let translation = fromGesture.translation(in: transitionContext.containerView)
                
                // Calculate the percent complete
                let percentComplete: CGFloat = self.transitionAnimator.fractionComplete + CompletionPositionConverter.progressStepFor(isForward: self.isForward, translation: translation, containerView: self.transitionContext.containerView)
                
                // Update the transition animator's fractionCompete to scrub it's animations
                self.transitionAnimator.fractionComplete = percentComplete
                
                // Inform the transition context of the updated percent complete
                self.transitionContext.updateInteractiveTransition(percentComplete)
                                
                // Reset the gestures translation
                fromGesture.setTranslation(.zero, in: transitionContext.containerView)
            case .ended, .cancelled:
                // End the interactive phase of the transition
                endInteraction()
            default: break
        }
    }
    
    func endInteraction() {
        // Ensure the context is currently interactive
        guard self.transitionContext.isInteractive else { return }
        
        // Inform the transition context of whether we are finishing or cancelling the transition
        let completionPosition: UIViewAnimatingPosition = CompletionPositionConverter.completionPosition(isForward: self.isForward, containerView: self.transitionContext.containerView, gestureRecognizer: self.gestureRecognizer, animatorProgress: self.transitionAnimator.fractionComplete)
        
        if completionPosition == .end {
            transitionContext.finishInteractiveTransition()
        } else {
            transitionContext.cancelInteractiveTransition()
        }
        
        // Begin the animation phase of the transition to either the start or finsh position
        animate(completionPosition)
    }
}

// MARK: - Transition Driver / Animation Manipulation
private extension MarksPane.ViewController.TransitionController.TransitionDriver {
    func animate(_ toPosition: UIViewAnimatingPosition) {
        // Check if we have reversed animation
        self.transitionAnimator.isReversed = (toPosition == .start)
        
        // Animate if we are not animating
        if transitionAnimator.state == .inactive {
            transitionAnimator.startAnimation()
        } else {
            let durationFactor = self.transitionAnimator.fractionComplete * CGFloat(self.transitionAnimator.duration)
            self.transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        }
    }
    
    func pauseAnimation() {
        // Pause the transition animator
        self.transitionAnimator.pauseAnimation()
        
        // Inform the transition context that we have paused
        self.transitionContext.pauseInteractiveTransition()
    }
}
