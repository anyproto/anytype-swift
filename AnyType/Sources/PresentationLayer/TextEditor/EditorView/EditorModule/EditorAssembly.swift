import SwiftUI

final class EditorAssembly {
    typealias Request = EditorModuleContainerViewBuilder.Request
    
    func documentView(by request: Request) -> some View {
        EditorModuleContainerViewRepresentable(documentId: request.id).eraseToAnyView()
    }
    
    func documentView(by request: Request, shouldShowDocument: Binding<Bool>) -> some View {
        EditorModuleContainerViewRepresentable(documentId: request.id, shouldShowDocument: shouldShowDocument).eraseToAnyView()
    }
}
