import UIKit
import SwiftEntryKit
import Combine
import Services

protocol ToastPresenterProtocol: AnyObject {
    func show(message: String)
    func show(message: String, mode: ToastPresenterMode)
    func show(message: NSAttributedString, mode: ToastPresenterMode)
    func dismiss(completion: @escaping () -> Void)
    
    func showObjectName(
        _ firstObjectName: String,
        middleAction: String,
        secondObjectId: BlockId,
        tapHandler: @escaping () -> Void
    )
    func showObjectCompositeAlert(prefixText: String, objectId: BlockId, tapHandler: @escaping () -> Void)
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
    private let documentsProvider: DocumentsProviderProtocol
    private var cancellable: AnyCancellable?

    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        containerViewController: UIViewController? = nil,
        keyboardHeightListener: KeyboardHeightListener,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.containerViewController = containerViewController
        self.keyboardHeightListener = keyboardHeightListener
        self.documentsProvider = documentsProvider
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
        
        let toastView = ToastView(frame: .zero)
        toastView.setMessage(attributedMessage)
        
        var attributes = EKAttributes()
        attributes.positionConstraints = .float
        attributes.windowLevel = .alerts
        attributes.entranceAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.exitAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.positionConstraints.size = .init(width: .offset(value: 16), height: .intrinsic)
        attributes.positionConstraints.verticalOffset = verticalOffset(using: mode, toastView: toastView)
        attributes.position = .bottom
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 5, offset: .zero))
        attributes.precedence = .enqueue(priority: .normal)
        
        SwiftEntryKit.display(entry: toastView, using: attributes)
    }
    
    func dismiss(completion: @escaping () -> Void) {
        SwiftEntryKit.dismiss(.all, with: completion)
    }
    
    func showObjectName(
        _ firstObjectName: String,
        middleAction: String,
        secondObjectId: BlockId,
        tapHandler: @escaping () -> Void
    ) {
        let objectAttributedString = NSMutableAttributedString(
            string: firstObjectName.trimmed(numberOfCharacters: 16),
            attributes: ToastView.objectAttributes
        )
        objectAttributedString.append(.init(string: " "))
        objectAttributedString.append(.init(string: middleAction, attributes: ToastView.defaultAttributes))
        
        showObjectCompositeAlert(
            p1: objectAttributedString,
            objectId: secondObjectId,
            tapHandler: tapHandler
        )
    }
    
    func showObjectCompositeAlert(prefixText: String, objectId: BlockId, tapHandler: @escaping () -> Void) {
        showObjectCompositeAlert(
            p1: .init(string: prefixText, attributes: ToastView.defaultAttributes),
            objectId: objectId,
            tapHandler: tapHandler
        )
    }
    
    private func verticalOffset(using mode: ToastPresenterMode, toastView: ToastView) -> CGFloat {
        guard let view = viewControllerProvider.rootViewController?.view else {
            return .zero
        }
        
        let bottomModeOffset: CGFloat
       
        switch mode {
        case .aboveKeyboard:
            let containerViewController = containerViewController ?? viewControllerProvider.topVisibleController
        
            bottomModeOffset = containerViewController?.bottomToastOffset ?? 0
            
            let bottomSafeArea = viewControllerProvider.window?.safeAreaInsets.bottom ?? 0
            let inset = max(keyboardHeightListener.currentKeyboardFrame.height - bottomModeOffset - bottomSafeArea, 0)
            toastView.updateBottomInset(inset)
            
            cancellable = keyboardHeightListener.animationChangePublisher.sink { [weak self] animation in
                let bottomSafeArea = self?.viewControllerProvider.window?.safeAreaInsets.bottom ?? 0
                let inset = max(animation.rect.height - bottomModeOffset - bottomSafeArea, 0)
                UIView.animate(withDuration: animation.duration, delay: 0, options: animation.options) {
                    toastView.updateBottomInset(inset)
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
    
    private func showObjectCompositeAlert(
        p1: NSAttributedString,
        objectId: BlockId,
        tapHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            guard let details = await retrieveObjectDetails(objectId: objectId) else {
                return
            }
            
            let compositeAttributedString = NSMutableAttributedString()
            let iconObjectAttributedString = await createAttributedString(from: details)
            
            compositeAttributedString.append(iconObjectAttributedString)
            
            let attributedString = NSMutableAttributedString(attributedString: p1)
            attributedString.append(.init(string: "  "))
            
            let tappableAttributedString = NSMutableAttributedString(attributedString: iconObjectAttributedString)
            
            let dismissableTapHandler: () -> Void = { [weak self] in
                self?.dismiss { tapHandler() }
            }
            
            tappableAttributedString.addAttributes([.tapHandler: dismissableTapHandler], range: tappableAttributedString.wholeRange)
            
            attributedString.append(tappableAttributedString)
            
            show(message: attributedString, mode: .aboveKeyboard)
        }
    }
    
    private func createAttributedString(from objectDetails: ObjectDetails) async -> NSAttributedString {
        guard let Icon = objectDetails.objectIconImage else {
            return await NSAttributedString(
                string: objectDetails.title.trimmed(numberOfCharacters: 16),
                attributes: ToastView.objectAttributes
            )
        }
        let maker = IconMaker(icon: Icon, size: CGSize(width: 16, height: 16))
        let image = await maker.make()
        return await NSAttributedString.imageFirstComposite(
            image: image,
            text: objectDetails.title.trimmed(numberOfCharacters: 16),
            attributes: ToastView.objectAttributes
        )
    }
    
    private func retrieveObjectDetails(objectId: BlockId) async -> ObjectDetails? {
        let targetDocument = documentsProvider.document(objectId: objectId, forPreview: true)
        try? await targetDocument.openForPreview()
        
        return targetDocument.details
    }
}
