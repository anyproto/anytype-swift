import SwiftUI

final class OldHomeCoordinator {
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
        
        let view = editorAssembly.documentView(id: selectedDocumentId, shouldShowDocument: shouldShowDocument).eraseToAnyView()
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
}
