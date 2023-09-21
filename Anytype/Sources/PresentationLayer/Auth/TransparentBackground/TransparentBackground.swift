import SwiftUI

struct TransparentBackground: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TransparentBackground>) -> UIViewController {
        return Controller()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<TransparentBackground>) {
    }
    
    class Controller: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            parent?.view?.backgroundColor = .clear
        }
    }
}
