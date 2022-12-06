import UIKit
import SwiftEntryKit

protocol ToastPresenterProtocol: AnyObject {
    func show(message: String)
    func show(message: NSAttributedString, mode: ToastPresenterMode)
    func dismiss(completion: @escaping () -> Void)
}

enum ToastPresenterMode {
    case aboveKeyboard
    case aboveView(UIView)
}

class ToastPresenter: ToastPresenterProtocol {
    static var shared: ToastPresenter?
    
    private var isShowing: Bool = false

    private let viewControllerProvider: ViewControllerProviderProtocol
    private weak var containerViewController: UIViewController?
    
    private let keyboardHeightListener: KeyboardHeightListener
    
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
        show(message: .init(string: message), mode: .aboveKeyboard)
    }
    
    func show(message: NSAttributedString, mode: ToastPresenterMode) {
        let attributedMessage = NSMutableAttributedString(attributedString: message)
        attributedMessage.addAttributes(Self.defaultAttributes, range: attributedMessage.wholeRange)
        
        toastView.setMessage(attributedMessage)
        
        var attributes = EKAttributes()
        attributes.positionConstraints = .float
        attributes.windowLevel = .alerts
        attributes.entranceAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.exitAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.positionConstraints.size = .init(width: .intrinsic, height: .intrinsic)
        attributes.positionConstraints.verticalOffset = verticalOffset(using: mode)
        attributes.position = .bottom
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 5, offset: .zero))
        attributes.statusBar = .currentStatusBar

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
            let containerViewController = containerViewController ?? viewControllerProvider.rootViewController
        
            bottomModeOffset = max(keyboardHeightListener.currentKeyboardHeight, containerViewController?.bottomToastOffset ?? 0)
        case .aboveView(let aboveView):
            let point = view.convert(aboveView.bounds.origin, from: aboveView)
            bottomModeOffset = view.bounds.height - point.y - view.safeAreaInsets.bottom
        }
    
        return bottomModeOffset + 8
    }
}

extension ToastPresenter {
    static var defaultAttributes: [NSAttributedString.Key : Any] {
        [.font: UIFont.caption1Medium, .foregroundColor: UIColor.textWhite]
    }
}
