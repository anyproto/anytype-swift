import UIKit

final class GalleryViewTransitionAnimator: NSObject {
    enum PresentationType {
        case present
        case dismiss
    }

    private struct Contants {
        static let duration = 0.3
    }

    init(
        presentationType: PresentationType,
        fromImageView: UIImageView,
        toImageView: UIImageView
    ) {
        self.presentationType = presentationType
        self.fromImageView = fromImageView
        self.toImageView = toImageView

        super.init()
    }

    private let presentationType: PresentationType
    private var transitionContext: UIViewControllerContextTransitioning?
    private weak var fromViewController: UIViewController?
    private weak var toViewController: UIViewController?

    private weak var fromImageView: UIImageView?
    private weak var toImageView: UIImageView?
    private weak var animatingImageView: UIImageView?

    func prepare() {
        prepareContainerView()
        prepareImageViews()
    }

    fileprivate func prepareContainerView() {
        guard presentationType == .present,
            let transitionContainerView = transitionContext?.containerView,
            let fromView = fromViewController?.view,
            let toView = toViewController?.view else {
                return
            }

        transitionContainerView.insertSubview(toView, aboveSubview: fromView)
    }

    fileprivate func prepareImageViews() {
        guard
            let transitionContainerView = transitionContext?.containerView,
            let fromImageView = fromImageView,
            let toImageView = toImageView else {
                transitionContext?.completeTransition(false)
                return
            }

        let animationView = UIImageView(image: fromImageView.image)

        transitionContainerView.addSubview(animationView)
        self.animatingImageView = animationView

        switch presentationType {
        case .present:
            fromImageView.globalFrame.map { animationView.frame = $0 }
        case .dismiss:
            toImageView.globalFrame.map { animationView.frame = $0 }
        }

        fromImageView.isHidden = true
        toImageView.isHidden = true
    }

    private func performZoomAnimation(reverse shouldAnimateInReverse: Bool) {
        guard let fromImageView = fromImageView,
              let toImageView = toImageView,
              let animatingImageView = animatingImageView,
              let initialRect = fromImageView.globalFrame,
              let finalRect = toImageView.globalFrame else {
                  transitionContext?.completeTransition(false)
                  return
              }


        if !shouldAnimateInReverse {
            animatingImageView.clipsToBounds = fromImageView.clipsToBounds
            animatingImageView.contentMode = fromImageView.contentMode
            animatingImageView.layer.cornerRadius = toImageView.layer.cornerRadius
        }

        let rectToMove: CGRect
        if presentationType == .present {
            rectToMove = shouldAnimateInReverse ? initialRect : finalRect
        } else {
            rectToMove = shouldAnimateInReverse ? finalRect : initialRect
        }

        UIView.animate(
            withDuration: Contants.duration,
            delay: 0,
            options: .curveLinear
        ) {
            animatingImageView.frame = rectToMove
        } completion: {  [weak self] didComplete in
            guard let self = self else { return }
            if didComplete {
                animatingImageView.removeFromSuperview()
                self.animatingImageView = nil

                fromImageView.isHidden = false
                toImageView.isHidden = false

                if shouldAnimateInReverse {
                    self.transitionContext?.cancelInteractiveTransition()
                    self.transitionContext?.completeTransition(false)
                } else {
                    self.transitionContext?.finishInteractiveTransition()
                    self.transitionContext?.completeTransition(true)
                }
            }
        }
    }

    func updateInteractiveTransition(_ translation: CGPoint) {
        guard let animationView = animatingImageView else {
            transitionContext?.completeTransition(false)
            return
        }

        animationView.frame = animationView.frame.offsetBy(dx: translation.x, dy: translation.y)
    }

    func finishInteractiveTransition() {
        performZoomAnimation(reverse: false)
    }


    func cancelInteractiveTransition() {
        performFadeAnimation(reverse: true)
        performZoomAnimation(reverse: true)
    }

    private func performFadeAnimation(reverse shouldAnimateInReverse: Bool) {
        guard
            let fromViewController = fromViewController,
            let toViewController = toViewController else {
                transitionContext?.completeTransition(false)
                return
            }

        let viewControllerToAnimate: UIViewController
        let initialAlpha: CGFloat
        let finalAlpha: CGFloat

        switch presentationType {
        case .present:
            viewControllerToAnimate = toViewController
            initialAlpha = 0
            finalAlpha = 1
        case .dismiss:
            viewControllerToAnimate = fromViewController
            initialAlpha = 1
            finalAlpha = 0
        }

        viewControllerToAnimate.view.alpha = shouldAnimateInReverse ? finalAlpha : initialAlpha

        UIView.animate(withDuration: Contants.duration, animations: {
            viewControllerToAnimate.view.alpha = shouldAnimateInReverse ? initialAlpha : finalAlpha
        })
    }
    
}

extension GalleryViewTransitionAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Contants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        startInteractiveTransition(transitionContext)
        finishInteractiveTransition()
    }
}

extension GalleryViewTransitionAnimator: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

        prepare()
        performFadeAnimation(reverse: false)
    }
}

private extension UIView {
    var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.superview?.convert(self.frame, to: rootView)
    }
}
