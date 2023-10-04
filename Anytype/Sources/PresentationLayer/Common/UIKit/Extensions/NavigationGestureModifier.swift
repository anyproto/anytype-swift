import Foundation
import SwiftUI

extension View {
    func fixNavigationBarGesture() -> some View {
        self.background {
            FixNavigationView().frame(width: 0, height: 0)
        }
    }
}

private struct FixNavigationView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> FixNavigationViewController {
        FixNavigationViewController()
    }
    
    func updateUIViewController(_ uiViewController: FixNavigationViewController, context: Context) {}
}

private final class FixNavigationViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
