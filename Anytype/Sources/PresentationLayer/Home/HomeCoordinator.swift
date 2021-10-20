import SwiftUI

final class HomeCoordinator {
    
    // MARK: - Private variables
    
    private let editorAssembly: EditorAssembly
    
    // MARK: - Initializers
    
    init(editorAssembly: EditorAssembly) {
        self.editorAssembly = editorAssembly
    }
    
    // MARK: - Internal functions
    
    func documentView(selectedDocumentId: String) -> some View {
        editorAssembly.editor(blockId: selectedDocumentId)
            .eraseToAnyView()
            .edgesIgnoringSafeArea(.all)
    }
    
}
