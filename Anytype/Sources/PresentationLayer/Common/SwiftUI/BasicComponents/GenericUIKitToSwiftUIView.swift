import SwiftUI

struct GenericUIKitToSwiftUIView: UIViewControllerRepresentable {
    let viewController: UIViewController

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }
}
