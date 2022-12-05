import Foundation
import SwiftUI
import Combine
import os
import AnytypeCore

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let data: EditorScreenData
    let model: HomeViewModel
    let editorBrowserAssembly: EditorBrowserAssembly
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorBrowserController {
        let browser = editorBrowserAssembly.buildEditorBrowser(data: data)
        model.editorBrowser = browser
        return browser
    }
    
    func updateUIViewController(
        _ uiViewController: EditorBrowserController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
