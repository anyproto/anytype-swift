import UIKit
import SwiftEntryKit
import Combine
import Services

@MainActor
protocol ToastPresenterProtocol: AnyObject {
    func show(message: String)
    func show(message: NSAttributedString)
    func dismiss(completion: @escaping () -> Void)
    
    func showObjectName(
        _ firstObjectName: String,
        middleAction: String,
        secondObjectId: String,
        tapHandler: @escaping () -> Void
    )
    func showObjectCompositeAlert(prefixText: String, objectId: String, tapHandler: @escaping () -> Void)
}

class ToastPresenter: ToastPresenterProtocol {
    static var shared: ToastPresenter? // Used only for SwiftUI

    @Injected(\.documentsProvider)
    private var documentsProvider: DocumentsProviderProtocol
    
    nonisolated init() {}
    
    // MARK: - ToastPresenterProtocol
    
    func show(message: String) {
        let attributedString = NSAttributedString(
            string: message,
            attributes: ToastView.defaultAttributes
        )
        show(message: attributedString)
    }
    
    func show(message: NSAttributedString) {
        let attributedMessage = NSMutableAttributedString(attributedString: message)
        
        let toastView = ToastView(frame: .zero)
        toastView.setMessage(attributedMessage)
        
        var attributes = EKAttributes()
        attributes.windowLevel = .alerts
        attributes.entranceAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.exitAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.positionConstraints.size = .init(width: .offset(value: 16), height: .intrinsic)
        attributes.position = .top
        attributes.roundCorners = .all(radius: 8)
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
        secondObjectId: String,
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
    
    func showObjectCompositeAlert(prefixText: String, objectId: String, tapHandler: @escaping () -> Void) {
        showObjectCompositeAlert(
            p1: .init(string: prefixText, attributes: ToastView.defaultAttributes),
            objectId: objectId,
            tapHandler: tapHandler
        )
    }
    
    private func showObjectCompositeAlert(
        p1: NSAttributedString,
        objectId: String,
        tapHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            guard let details = await retrieveObjectDetails(objectId: objectId) else {
                return
            }
            
            let compositeAttributedString = NSMutableAttributedString()
            let iconObjectAttributedString = createAttributedString(from: details)
            
            compositeAttributedString.append(iconObjectAttributedString)
            
            let attributedString = NSMutableAttributedString(attributedString: p1)
            attributedString.append(.init(string: "  "))
            
            let tappableAttributedString = NSMutableAttributedString(attributedString: iconObjectAttributedString)
            
            let dismissableTapHandler: () -> Void = { [weak self] in
                self?.dismiss { tapHandler() }
            }
            
            tappableAttributedString.addAttributes([.tapHandler: dismissableTapHandler], range: tappableAttributedString.wholeRange)
            
            attributedString.append(tappableAttributedString)
            
            show(message: attributedString)
        }
    }
    
    private func createAttributedString(from objectDetails: ObjectDetails) -> NSAttributedString {
        return NSAttributedString(
            string: objectDetails.title.trimmed(numberOfCharacters: 16),
            attributes: ToastView.objectAttributes
        )
    }
    
    private func retrieveObjectDetails(objectId: String) async -> ObjectDetails? {
        let targetDocument = documentsProvider.document(objectId: objectId, forPreview: true)
        try? await targetDocument.openForPreview()
        
        return targetDocument.details
    }
}
