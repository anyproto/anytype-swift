import SwiftUI

final class ProfileCoordinator {
    private let editorAssembly: EditorAssembly
    init(editorAssembly: EditorAssembly) {
        self.editorAssembly = editorAssembly
    }
    
    func openProfile(profileId: String?) -> some View {
        let profileId = profileId ?? ""
        
        return editorAssembly.documentView(
            by: .init(id: profileId)
        )
    }}
