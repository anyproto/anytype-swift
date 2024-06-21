import UIKit
import Services
import AnytypeCore

extension ToastPresenterProtocol {
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
        
        show(message: attributedString)
    }
}

