import Foundation
import SwiftUI
import Combine
import os
import AnytypeCore

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let data: EditorScreenData
    let model: HomeViewModel
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorBrowserController {
        let browser = EditorBrowserAssembly().buildEditorBrowser(data: data)
        model.editorBrowser = browser
        return browser
    }
    
    func updateUIViewController(
        _ uiViewController: EditorBrowserController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
