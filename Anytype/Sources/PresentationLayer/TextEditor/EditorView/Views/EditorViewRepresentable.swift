import Foundation
import SwiftUI
import Combine
import os

struct EditorViewRepresentable: UIViewControllerRepresentable {
    
    let blockId: String
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) -> EditorNavigationViewController {
        EditorAssembly().buildRootEditor(blockId: blockId)
    }
    
    func updateUIViewController(
        _ uiViewController: EditorNavigationViewController,
        context: UIViewControllerRepresentableContext<EditorViewRepresentable>
    ) { }
}
