import UIKit
import BlocksModels

extension ToastPresenterProtocol {
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
    
    /// Alert with a tick image at the first place
    func showSuccessAlert(message: String) {
        showMessage(message, assetIcon: .toastTick)
    }
    
    func showFailureAlert(message: String) {
        showMessage(message, assetIcon: .toastFailure)
    }
    
    func showMessage(_ message: String, assetIcon: ImageAsset) {
        guard let image = UIImage(asset: assetIcon) else { return }
        
        let attributedString = NSAttributedString.imageFirstComposite(
            image: image,
            text: message,
            attributes: ToastView.defaultAttributes
        )
        
        show(message: attributedString, mode: .aboveKeyboard)
    }
    
    private func showObjectCompositeAlert(
        p1: NSAttributedString,
        objectId: BlockId,
        tapHandler: @escaping () -> Void
    ) {
        Task { @MainActor [weak self] in
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
            
            self?.show(message: attributedString, mode: .aboveKeyboard)
        }
    }
}

// MARK: - Private

private func retrieveObjectDetails(objectId: BlockId) async -> ObjectDetails? {
    let targetDocument = BaseDocument(objectId: objectId)
    try? await targetDocument.open()
    
    return targetDocument.details
}

private func createAttributedString(from objectDetails: ObjectDetails) async -> NSAttributedString {
    guard let icon = objectDetails.icon else {
        return await NSAttributedString(
            string: objectDetails.name.trimmed(numberOfCharacters: 16),
            attributes: ToastView.objectAttributes
        )
    }
    
    let loader = AnytypeIconDownloader()
    
    guard let image = await loader.image(
        with: icon,
        imageGuideline: .init(size: .init(width: 16, height: 16))
    ) else {
        return .init(string: objectDetails.name)
    }
    
    return await NSAttributedString.imageFirstComposite(
        image: image,
        text: objectDetails.name.trimmed(numberOfCharacters: 16),
        attributes: ToastView.objectAttributes
    )
}

