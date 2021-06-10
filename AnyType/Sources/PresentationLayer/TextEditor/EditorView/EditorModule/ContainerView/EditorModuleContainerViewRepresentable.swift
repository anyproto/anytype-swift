import Foundation
import SwiftUI
import Combine
import os

struct EditorModuleContainerViewRepresentable: UIViewControllerRepresentable {
    
    let documentId: String
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>
    ) -> DocumentEditorViewController {
        DocumentEditorBuilder.build(id: documentId)
    }
    
    func updateUIViewController(
        _ uiViewController: DocumentEditorViewController,
        context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>
    ) {
    }
    
}
