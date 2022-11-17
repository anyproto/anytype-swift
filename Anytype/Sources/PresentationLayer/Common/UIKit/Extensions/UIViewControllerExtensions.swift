import UIKit
import SwiftUI


extension UIViewController {
    
    func setupBackBarButtonItem(_ item: UIBarButtonItem?) {
        navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = item
        
        // This trick enables screen edge pan gesture after setting left bar button.
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func presentSwiftUIView<Content: View>(view: Content, model: Dismissible?) {
        let controller = UIHostingController(rootView: view)
        model?.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        present(controller, animated: true)
    }
}
