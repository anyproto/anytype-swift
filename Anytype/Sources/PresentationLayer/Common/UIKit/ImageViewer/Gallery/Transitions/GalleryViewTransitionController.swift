import UIKit

final class GalleryViewTransitionController: NSObject {
    private struct Constants {
        static let dismissTranslationThreshold: CGFloat = 150
    }

    var imageViewerImageView: (() -> UIImageView?)?
    var presenterImageView: UIImageView?
    weak var galleryViewController: UIViewController?

    private var dismissAnimator: GalleryViewTransitionAnimator?

    private var shouldDismissInteractively: Bool = false
    private var lastPanTranslation: CGPoint?

    func didPan(withGestureRecognizer gestureRecognizer: UIPanGestureRecognizer, sourceView: UIView) {
        switch gestureRecognizer.state {
        case .began:
            guard let imageView = imageViewerImageView?() else {
                return
            }

            let touchLocation = gestureRecognizer.location(in: sourceView)
            let imageViewFrame = imageView.superview?.convert(imageView.frame, to: sourceView)

            if imageViewFrame?.contains(touchLocation) == true {
                lastPanTranslation = gestureRecognizer.translation(in: sourceView)
                shouldDismissInteractively = true

                galleryViewController?.dismiss(animated: true, completion: nil)
            }
        case .changed:
            guard shouldDismissInteractively,
                  let dismissAnimator = dismissAnimator,
                  let lastPanTranslation = lastPanTranslation else {
                      return
                  }

            let translation = gestureRecognizer.translation(in: sourceView)

            let translationDelta = CGPoint(x: translation.x - lastPanTranslation.x,
                                           y: translation.y - lastPanTranslation.y)
            dismissAnimator.updateInteractiveTransition(translationDelta)

            self.lastPanTranslation = translation
        case .ended:
            guard
                shouldDismissInteractively,
                let dismissAnimator = dismissAnimator else {
                    return
                }

            let translation = gestureRecognizer.translation(in: sourceView)

            if abs(translation.x) > Constants.dismissTranslationThreshold ||
                abs(translation.y) > Constants.dismissTranslationThreshold {
                dismissAnimator.finishInteractiveTransition()
            } else {
                dismissAnimator.cancelInteractiveTransition()
            }

            lastPanTranslation = nil
            self.dismissAnimator = nil
            shouldDismissInteractively = false
        default:
            return
        }
    }
}

extension GalleryViewTransitionController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let presenterImageView = presenterImageView,
              let imageViewerImageView = imageViewerImageView?() else {
                  return nil
              }

        return GalleryViewTransitionAnimator(
            presentationType: .present,
            fromImageView: presenterImageView,
            toImageView: imageViewerImageView
        )
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presenterImageView = presenterImageView,
              let imageViewerImageView = imageViewerImageView?() else {
                  return nil
              }

        dismissAnimator = GalleryViewTransitionAnimator(
            presentationType: .dismiss,
            fromImageView: presenterImageView,
            toImageView: imageViewerImageView
        )

        return dismissAnimator
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        guard shouldDismissInteractively && animator === dismissAnimator else {
            return nil
        }

        return dismissAnimator
    }
}
