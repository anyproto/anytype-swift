import Foundation
import SwiftUI
import Combine
import os

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let documentId: String
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorNavigationViewController {
        let navigationController = UINavigationController(
            rootViewController: EditorAssembly.buildEditor(blockId: documentId)
        )
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navigationController.modifyBarAppearance(navBarAppearance)
        
        return EditorNavigationViewController(
            child: navigationController
        )
    }
    
    func updateUIViewController(
        _ uiViewController: EditorNavigationViewController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
