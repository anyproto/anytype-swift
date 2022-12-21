import UIKit
import BlocksModels

extension ToastPresenterProtocol {
    func showObjectCompositeAlert(
        p1: String,
        objectId: BlockId,
        tapHandler: @escaping () -> Void
    ) {
        Task { @MainActor [weak self] in
            guard let details = await retrieveObjectDetails(objectId: objectId) else {
                return
            }
            
            let iconObjectAttributedString = await createAttributedString(from: details)
            
            let attributedString = NSMutableAttributedString(string: p1 + "  ")
            
            let tappableAttributedString = NSMutableAttributedString(attributedString: iconObjectAttributedString)
            
            let dismissableTapHandler: () -> Void = { [weak self] in
                self?.dismiss { tapHandler() }
            }
            
            tappableAttributedString.addAttributes([.tapHandler: dismissableTapHandler], range: tappableAttributedString.wholeRange)
            
            attributedString.append(tappableAttributedString)
            
            self?.show(message: attributedString, mode: .aboveKeyboard)
        }
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
            attributes: ToastPresenter.defaultAttributes
        )
        
        show(message: attributedString, mode: .aboveKeyboard)
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
        return .init(string: objectDetails.name)
    }
    
    let loader = AnytypeIconDownloader()
    
    guard let image = await loader.image(
        with: icon,
        imageGuideline: .init(size: .init(width: 16, height: 16))
    ) else {
        return .init(string: objectDetails.name)
    }
    
    return NSAttributedString.imageFirstComposite(
        image: image,
        text: objectDetails.name,
        attributes: [.foregroundColor: UIColor.Text.primary]
    )
}
