import SwiftUI
import BlocksModels

final class EditorAssembly {
    
    func documentView(id: BlockId) -> some View {
        EditorViewRepresentable(documentId: id).eraseToAnyView()
    }
    
    static func build(id: BlockId) -> DocumentEditorViewController {
        let selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
        
        let editorViewModel = DocumentEditorViewModel(
            documentId: id,
            selectionHandler: selectionHandler
        )
        
        let editorController = DocumentEditorViewController(viewModel: editorViewModel)
        
        editorViewModel.viewInput = editorController
        editorViewModel.router = EditorRouter(
            preseningViewController: editorController
        )
        
        return editorController
    }
}
