import SwiftUI

final class EditorAssembly {
    typealias Request = EditorModule.Container.ViewBuilder.Request
    
    func documentView(by request: Request) -> some View {
        self.create(by: request)
    }
    
    func documentView(by request: Request, shouldShowDocument: Binding<Bool>) -> some View {
        self.create(by: request, shouldShowDocument: shouldShowDocument)
    }
    
    private typealias CurrentViewRepresentable = EditorModule.Container.ViewRepresentable
    
    private func create(by request: Request) -> AnyView {
        .init(CurrentViewRepresentable.create(documentId: request.id))
    }
    
    private func create(by request: Request, shouldShowDocument: Binding<Bool>) -> AnyView {
        .init(CurrentViewRepresentable.create(documentId: request.id, shouldShowDocument: shouldShowDocument))
    }
}
