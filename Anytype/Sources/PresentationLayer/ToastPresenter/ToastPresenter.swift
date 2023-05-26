import UIKit
import SwiftEntryKit
import Combine

protocol ToastPresenterProtocol: AnyObject {
    func show(message: String)
    func show(message: String, mode: ToastPresenterMode)
    func show(message: NSAttributedString, mode: ToastPresenterMode)
    func dismiss(completion: @escaping () -> Void)
}

enum ToastPresenterMode {
    case aboveKeyboard
    case aboveView(UIView)
}

class ToastPresenter: ToastPresenterProtocol {
    static var shared: ToastPresenter? // Used only for SwiftUI

    private let viewControllerProvider: ViewControllerProviderProtocol
    private weak var containerViewController: UIViewController?
    
    private let keyboardHeightListener: KeyboardHeightListener
    private var cancellable: AnyCancellable?
    private lazy var toastView = ToastView(frame: .zero)

    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        containerViewController: UIViewController? = nil,
        keyboardHeightListener: KeyboardHeightListener
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.containerViewController = containerViewController
        self.keyboardHeightListener = keyboardHeightListener
    }

    // MARK: - ToastPresenterProtocol
    
    func show(message: String) {
        show(message: message, mode: .aboveKeyboard)
    }
    
    func show(message: String, mode: ToastPresenterMode) {
        let attributedString = NSAttributedString(
            string: message,
            attributes: ToastView.defaultAttributes
        )
        show(message: attributedString, mode: mode)
    }
    
    func show(message: NSAttributedString, mode: ToastPresenterMode) {
        let attributedMessage = NSMutableAttributedString(attributedString: message)
        
        toastView.setMessage(attributedMessage)
        
        var attributes = EKAttributes()
        attributes.positionConstraints = .float
        attributes.windowLevel = .alerts
        attributes.entranceAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.exitAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.positionConstraints.size = .init(width: .offset(value: 16), height: .intrinsic)
        attributes.positionConstraints.verticalOffset = verticalOffset(using: mode)
        attributes.position = .bottom
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 5, offset: .zero))
        attributes.statusBar = .currentStatusBar
        attributes.precedence = .enqueue(priority: .normal)
        
        SwiftEntryKit.display(entry: toastView, using: attributes)
    }
    
    func dismiss(completion: @escaping () -> Void) {
        SwiftEntryKit.dismiss(.all, with: completion)
    }
    
    private func verticalOffset(using mode: ToastPresenterMode) -> CGFloat {
        guard let view = viewControllerProvider.rootViewController?.view else {
            return .zero
        }
        
        let bottomModeOffset: CGFloat
       
        switch mode {
        case .aboveKeyboard:
            let containerViewController = containerViewController ?? viewControllerProvider.topVisibleController
        
            bottomModeOffset = containerViewController?.bottomToastOffset ?? 0
            
            cancellable = keyboardHeightListener.animationChangePublisher.sink { [weak self] animation in
                let bottomSafeArea = self?.viewControllerProvider.window?.safeAreaInsets.bottom ?? 0
                let inset = max(animation.rect.height - bottomModeOffset - bottomSafeArea, 0)
                UIView.animate(withDuration: animation.duration, delay: 0, options: animation.options) {
                    self?.toastView.updateBottomInset(inset)
                }
            }
        case .aboveView(let aboveView):
            toastView.updateBottomInset(0)
            cancellable = nil
            let point = view.convert(aboveView.bounds.origin, from: aboveView)
            bottomModeOffset = view.bounds.height - point.y - view.safeAreaInsets.bottom
        }
    
        return bottomModeOffset + 8
    }
}
