import Foundation
import SwiftUI
import Combine
import os

struct EditorModuleContainerViewRepresentable: UIViewControllerRepresentable {
    
    let documentId: String
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>
    ) -> EditorModuleContainerViewController {
        EditorModuleContainerViewBuilder.makeView(with: documentId)
    }
    
    func updateUIViewController(
        _ uiViewController: EditorModuleContainerViewController,
        context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>
    ) {
    }
    
}
