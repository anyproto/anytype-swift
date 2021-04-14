import SwiftUI
import BlocksModels

final class ProfileCoordinator {
    private let editorAssembly: EditorAssembly
    init(editorAssembly: EditorAssembly) {
        self.editorAssembly = editorAssembly
    }
    
    func openProfile(profileId: BlockId) -> some View {
        return editorAssembly.documentView(
            by: .init(id: profileId) 
        )
    }
}
