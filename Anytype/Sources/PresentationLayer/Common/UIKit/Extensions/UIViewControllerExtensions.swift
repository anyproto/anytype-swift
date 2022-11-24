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

    func dismissAndPresent(
        viewController: UIViewController,
        animateDismissing: Bool = false,
        animatePresenting: Bool = true
    ) {
        dismiss(animated: animateDismissing) { [weak self] in
            self?.present(viewController, animated: animatePresenting, completion: nil)
        }
    }
    
    func presentSwiftUIView<Content: View>(view: Content, model: Dismissible?) {
        let controller = UIHostingController(rootView: view)
        model?.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        present(controller, animated: true)
    }
}
