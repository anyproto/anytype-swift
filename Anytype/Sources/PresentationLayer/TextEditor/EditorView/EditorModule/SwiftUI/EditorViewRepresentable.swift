import Foundation
import SwiftUI
import Combine
import os

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let documentId: String
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> DocumentEditorViewController {
        EditorAssembly.build(id: documentId)
    }
    
    func updateUIViewController(
        _ uiViewController: DocumentEditorViewController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) {
    }
    
}
