import Foundation
import SwiftUI

private struct ShareViewWrapper<T>: UIViewControllerRepresentable {
    
    @Binding var item: T?

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let showItem = item {
            guard context.coordinator.activity.isNil else { return }
            let newActivity = UIActivityViewController(activityItems: [showItem], applicationActivities: nil)
            if UIDevice.isPad {
                newActivity.popoverPresentationController?.sourceView = uiViewController.view
                newActivity.popoverPresentationController?.sourceRect = uiViewController.view.bounds
            }
            newActivity.completionWithItemsHandler = { (_, _, _, _) in
                item = nil
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
    func anytypeShareView<T>(item: Binding<T?>) -> some View {
        self.overlay(
            ShareViewWrapper(item: item)
                .allowsHitTesting(false)
        )
    }
}


