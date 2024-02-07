import Foundation
import SwiftUI

private struct ShareViewWrapper: UIViewControllerRepresentable {
    
    @Binding var show: Bool
    var item: Any

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if show {
            guard context.coordinator.activity.isNil else { return }
            let newActivity = UIActivityViewController(activityItems: [item], applicationActivities: nil)
            if UIDevice.isPad {
                newActivity.popoverPresentationController?.sourceView = uiViewController.view
                newActivity.popoverPresentationController?.sourceRect = uiViewController.view.bounds
            }
            newActivity.completionWithItemsHandler = { (_, _, _, _) in
                show = false
            }
            context.coordinator.activity = newActivity
            uiViewController.present(newActivity, animated: true)
        } else {
            context.coordinator.activity?.dismiss(animated: true)
            context.coordinator.activity = nil
        }
    }
    
    func makeCoordinator() -> ShareViewCoordinator {
        ShareViewCoordinator()
    }
}

private final class ShareViewCoordinator {
    // Store local state in coordinator for prevent "undefined behavior" warning
    weak var activity: UIViewController?
}

extension View {
    func anytypeShareView(show: Binding<Bool>, item: Any) -> some View {
        self.overlay(
            ShareViewWrapper(show: show, item: item)
                .allowsHitTesting(false)
        )
    }
}


