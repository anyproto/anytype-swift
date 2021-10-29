import Foundation
import SwiftUI
import Combine
import os

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let blockId: String
    let model: HomeViewModel
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorBrowserController {
        let browser = EditorAssembly().buildEditorBrowser(blockId: blockId)
        model.editorBrowser = browser
        return browser
    }
    
    func updateUIViewController(
        _ uiViewController: EditorBrowserController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
