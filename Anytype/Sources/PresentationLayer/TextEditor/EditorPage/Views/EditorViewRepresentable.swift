import Foundation
import SwiftUI
import Combine
import os
import AnytypeCore

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let blockId: String
    let model: HomeViewModel
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorBrowserController {
        let type = model.document.detailsStorage.get(id: blockId)?.editorViewType
        if type.isNil {
            anytypeAssertionFailure("KNOWN ISSUE\nNo data for new page with id: \(blockId)")
        }
        
        let browser = EditorBrowserAssembly().buildEditorBrowser(blockId: blockId, type: type ?? .page)
        model.editorBrowser = browser
        return browser
    }
    
    func updateUIViewController(
        _ uiViewController: EditorBrowserController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
