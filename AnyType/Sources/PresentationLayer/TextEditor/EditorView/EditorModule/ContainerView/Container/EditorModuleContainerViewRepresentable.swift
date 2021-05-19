import Foundation
import SwiftUI
import Combine
import os

struct EditorModuleContainerViewRepresentable: UIViewControllerRepresentable {
    private(set) var documentId: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>) -> EditorModuleContainerViewController {
        return EditorModuleContainerViewBuilder.view(id: documentId)
    }
    
    func updateUIViewController(
        _ uiViewController: EditorModuleContainerViewController,
        context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>
    ) { }
}
