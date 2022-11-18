import UIKit

protocol ToastPresenterProtocol {
    func show(message: String)
}

class ToastPresenter: ToastPresenterProtocol {
    private var isShowing: Bool = false

    private let viewControllerProvider: ViewControllerProviderProtocol
    private lazy var toastView = ToastView(frame: .zero)

    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }

    // MARK: - ToastPresenterProtocol
    
    func show(message: String) {
        if isShowing { return }

        isShowing = true
        toastView.alpha = 0.0
        toastView.setMessage(message)

        viewControllerProvider.topViewController?.view.addSubview(toastView) {
            $0.pinToSuperview()
        }

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseOut, animations: {
                self.toastView.alpha = 0.0
                self.isShowing = false
            }, completion: { _ in
                self.toastView.removeFromSuperview()
            })
        })
    }
}


