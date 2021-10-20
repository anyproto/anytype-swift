import Foundation
import SwiftUI
import Combine
import os

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let blockId: String
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorBrowserController {
        EditorAssembly().buildRootEditor(blockId: blockId)
    }
    
    func updateUIViewController(
        _ uiViewController: EditorBrowserController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
