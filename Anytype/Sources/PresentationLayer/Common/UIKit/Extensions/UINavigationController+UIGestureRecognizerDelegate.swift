import UIKit
import SwiftUI

// TODO: Navigation: Delete it
final class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    var disableBackSwipe = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return disableBackSwipe ? false : viewControllers.count > 1
    }
}

extension View {
    func fixNavigationBarGesture() -> some View {
        self.background {
            FixNavigationView().frame(width: 0, height: 0)
        }
    }
}

struct FixNavigationView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> FixNavigationViewController {
        FixNavigationViewController()
    }
    
    func updateUIViewController(_ uiViewController: FixNavigationViewController, context: Context) {}
}

final class FixNavigationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fixBar()
    }
    
    private func fixBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController else { return false }
        return navigationController.viewControllers.count > 1
    }
}
