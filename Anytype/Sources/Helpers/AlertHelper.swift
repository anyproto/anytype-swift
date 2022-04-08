import Dispatch
import UIKit

final class AlertHelper {
    static func showToast(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
          alert.dismiss(animated: true, completion: nil)
        }
        
        WindowManager.shared.presentOnTop(alert, animated: true)
    }
}
