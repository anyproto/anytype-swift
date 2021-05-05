import SwiftUI

final class EditorAssembly {
    typealias Request = EditorModuleContainerViewBuilder.Request
    
    func documentView(by request: Request) -> some View {
        self.create(by: request)
    }
    
    func documentView(by request: Request, shouldShowDocument: Binding<Bool>) -> some View {
        self.create(by: request, shouldShowDocument: shouldShowDocument)
    }
    
    private func create(by request: Request) -> AnyView {
        .init(EditorModuleContainerViewRepresentable.create(documentId: request.id))
    }
    
    private func create(by request: Request, shouldShowDocument: Binding<Bool>) -> AnyView {
        .init(EditorModuleContainerViewRepresentable.create(documentId: request.id, shouldShowDocument: shouldShowDocument))
    }
}
