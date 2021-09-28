import UIKit

extension UIViewController {
    
    func setupBackBarButtonItem(_ item: UIBarButtonItem) {
        navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = item
        
        // This trick enables screen edge pan gesture after setting left bar button.
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}
