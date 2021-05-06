import Foundation
import SwiftUI
import Combine
import os

struct EditorModuleContainerViewRepresentable: UIViewControllerRepresentable {
    private(set) var documentId: String
    private(set) var shouldShowDocument: Binding<Bool> = .init(get: { false }, set: { value in })
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>) -> EditorModuleContainerViewController {
        let view = EditorModuleContainerViewBuilder.view(id: documentId)
        
        context.coordinator.configured(userActionStream: view.userActionPublisher)
        return view
    }
    
    func updateUIViewController(
        _ uiViewController: EditorModuleContainerViewController,
        context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>
    ) { }
    
    class Coordinator {
        typealias Parent = EditorModuleContainerViewRepresentable
        typealias IncomingAction = EditorModuleContainerViewController.UserAction
        
        private var parent: Parent
        private var subscription: AnyCancellable?
        
        init(_ parent: Parent) {
            self.parent = parent
        }
        
        func configured(userActionStream: AnyPublisher<IncomingAction, Never>) {
            self.subscription = userActionStream.sink(receiveValue: { [weak self] (value) in
                switch value {
                case .shouldDismiss: self?.dismiss()
                }
            })
        }
        
        func dismiss() {
            self.parent.shouldShowDocument.wrappedValue = false
        }
    }
}
