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
        EditorAssembly.buildRootEditor(blockId: documentId)
    }
    
    func updateUIViewController(
        _ uiViewController: EditorNavigationViewController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
