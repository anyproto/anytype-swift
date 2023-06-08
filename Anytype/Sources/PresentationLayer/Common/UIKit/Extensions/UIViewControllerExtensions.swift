import UIKit
import SwiftUI


extension UIViewController {
    
    @objc dynamic var bottomToastOffset: CGFloat { 0 }
    
    func presentSwiftUIView<Content: View>(view: Content, model: Dismissible?) {
        let controller = UIHostingController(rootView: view)
        model?.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        present(controller, animated: true)
    }
}
