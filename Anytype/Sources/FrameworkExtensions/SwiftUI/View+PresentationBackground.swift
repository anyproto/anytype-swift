import Foundation
import SwiftUI

extension View {
    // .presentationBackground(...) doesn't work correctly when screen contains child sheet
    // Also this method provide change background for ios 16.2. Set background in view
    func disablePresentationBackground() -> some View {
        background { BlurViewController() }
    }
}

private final class UIBlurController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.view.backgroundColor = .clear
    }
}

private struct BlurViewController: UIViewControllerRepresentable {
   
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIBlurController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

