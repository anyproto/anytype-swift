import SwiftUI

final class EditorAssembly {
    func documentView(id: String, shouldShowDocument: Binding<Bool>) -> some View {
        EditorModuleContainerViewRepresentable(documentId: id, shouldShowDocument: shouldShowDocument).eraseToAnyView()
    }
}
