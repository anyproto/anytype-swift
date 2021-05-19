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
    
    func documentView(selectedDocumentId: String) -> some View {
        return editorAssembly.documentView(id: selectedDocumentId).eraseToAnyView()
    }
}
