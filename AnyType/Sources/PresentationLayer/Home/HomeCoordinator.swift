import SwiftUI

final class HomeCoordinator {
    private let profileAssembly: ProfileAssembly
    private let editorAssembly: EditorAssembly
    init(
        profileAssembly: ProfileAssembly,
        editorAssembly: EditorAssembly
    ) {
        self.profileAssembly = profileAssembly
        self.editorAssembly = editorAssembly
    }
    
    func profileView() -> some View {
        profileAssembly.profileView()
    }
    
    
    // MARK: - Document view
    private var cachedDocumentView: AnyView?
    private var documentViewId: String = ""
    
    func documentView(selectedDocumentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view = AnyView(
            self.createDocumentView(documentId: selectedDocumentId, shouldShowDocument: shouldShowDocument)
        )
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
        
    private func createDocumentView(documentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        return editorAssembly.documentView(
            by: .init(id: documentId),
            shouldShowDocument: shouldShowDocument
        )
    }    
}
