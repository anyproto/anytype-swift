import SwiftUI

final class EditorAssembly {
    
    func documentView(id: String) -> some View {
        EditorModuleContainerViewRepresentable(documentId: id).eraseToAnyView()
    }
    
}
