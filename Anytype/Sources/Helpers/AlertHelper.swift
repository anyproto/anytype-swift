import Dispatch
import UIKit

final class AlertHelper {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showToast(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
          alert.dismiss(animated: true, completion: nil)
        }
        
        viewController?.topPresentedController.present(alert, animated: true)
    }
}
