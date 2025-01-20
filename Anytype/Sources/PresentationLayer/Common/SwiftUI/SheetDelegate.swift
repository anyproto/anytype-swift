import Foundation
import SwiftUI
import UIKit

extension View {
    func interactiveDismissDisabled(_ isDisable: Bool, attemptToDismiss: @escaping () -> Void) -> some View {
        background(SetSheetDelegateView(isDisable: isDisable, attemptToDismiss: attemptToDismiss))
    }
}

private struct SetSheetDelegateView: UIViewControllerRepresentable {
    
    let isDisable: Bool
    let attemptToDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.parent?.presentationController?.delegate = context.coordinator
        }
        context.coordinator.isDisable = isDisable
        context.coordinator.attemptToDismiss = attemptToDismiss
    }
    
    func makeCoordinator() -> SheetDelegate {
        SheetDelegate()
    }
}

private final class SheetDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    var isDisable: Bool = false
    var attemptToDismiss: (() -> Void)?

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        !isDisable
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        attemptToDismiss?()
    }
}
