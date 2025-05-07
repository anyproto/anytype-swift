import UIKit
import AnytypeCore
import Assets

public extension ToastManager {
    /// Alert with a tick image at the first place
    static func showSuccessAlert(message: String) {
        showMessage(message, assetIcon: .toastTick)
    }
    
    static func showFailureAlert(message: String) {
        showMessage(message, assetIcon: .toastFailure)
    }
    
    static func showMessage(_ message: String, assetIcon: ImageAsset) {
        guard let image = UIImage(asset: assetIcon) else { return }
        
        let attributedString = NSAttributedString.imageFirstComposite(
            image: image,
            text: message,
            attributes: ToastAttributes.defaultAttributes
        )
        
        show(message: attributedString)
    }
}
