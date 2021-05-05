import SwiftUI

final class EditorAssembly {
    func documentView(id: String) -> some View {
        EditorModuleContainerViewRepresentable(documentId: id).eraseToAnyView()
    }
    
    func documentView(id: String, shouldShowDocument: Binding<Bool>) -> some View {
        EditorModuleContainerViewRepresentable(documentId: id, shouldShowDocument: shouldShowDocument).eraseToAnyView()
    }
}
