import UIKit

class ToastPresenter {
    private var isShowing: Bool = false

    private let rootViewController: UIViewController

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func show(message: String) {
        if isShowing { return }

        isShowing = true

        let toastContainer = ThroughHitView(frame: .zero)
        toastContainer.backgroundColor = .clear
        toastContainer.alpha = 0.0

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = .textWhite
        toastLabel.textAlignment = .center;
        toastLabel.font = AnytypeFont.caption1Medium.uiKitFont
        toastLabel.text = message
        toastLabel.numberOfLines = 0

        let decoratedView = UIView()
        decoratedView.backgroundColor = .buttonActive
        decoratedView.layer.cornerRadius = 8
        decoratedView.layer.masksToBounds = true

        toastContainer.addSubview(decoratedView) {
            $0.centerX.equal(to: toastContainer.centerXAnchor)
        }

        NSLayoutConstraint(
            item: decoratedView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: toastContainer,
            attribute: .centerY,
            multiplier: 1.5,
            constant: 0
        ).isActive = true


        decoratedView.addSubview(toastLabel) {
            $0.pinToSuperview(insets: .init(top: 8, left: 8, bottom: -8, right: -8))
        }

        rootViewController.topPresentedController.view.addSubview(toastContainer) {
            $0.pinToSuperview()
        }

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
                self?.isShowing = false
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}

private class ThroughHitView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
