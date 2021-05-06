import SwiftUI
import BlocksModels

final class ProfileCoordinator {
    private let editorAssembly: EditorAssembly

    init(editorAssembly: EditorAssembly) {
        self.editorAssembly = editorAssembly
    }
    
    func openProfile(profileId: BlockId, shouldShowDocument: Binding<Bool>) -> some View {
        return editorAssembly.documentView(id: profileId, shouldShowDocument: shouldShowDocument)
    }
}
