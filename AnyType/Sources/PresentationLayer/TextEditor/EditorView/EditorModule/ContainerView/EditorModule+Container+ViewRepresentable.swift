import Foundation
import SwiftUI
import Combine
import os

extension EditorModule.Container {
    struct ViewRepresentable {
        @Environment(\.presentationMode) var presentationMode
        private(set) var documentId: String
        private(set) var shouldShowDocument: Binding<Bool> = .init(get: { false }, set: { value in })
    }
}

// MARK: - ContentViewRepresentable
extension EditorModule.Container.ViewRepresentable: UIViewControllerRepresentable {
    
    private typealias ViewBuilder = EditorModule.Container.ViewBuilder
    typealias ViewController = EditorModule.Container.ViewController
    typealias Me = EditorModule.Container.ViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Me>) -> ViewController {
        /// Configure document view builder.
//        let view = ViewBuilder.UIKitBuilder.documentView(by: .init(id: self.documentId))
        let view = ViewBuilder.UIKitBuilder.view(by: .init(id: self.documentId))
        
        // TODO: Fix later.
        // We should enable back button handling.
        /// Subscribe `coordinator` on events from `view.headerView`.
        /// TODO: Add back button here.
//        _ = context.coordinator.configured(headerViewModelPublisher: view.headerViewModelPublisher)
        
        context.coordinator.configured(userActionStream: view.userActionPublisher)
        
        return view
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<Me>) {
        // our model did change?
        // should we do something?
        // well, we should calculate diffs.
        // But not now.
        // later.
        
        // Do we need to reload table view data here?
        //        DispatchQueue.main.async {
        //            uiViewController.tableView?.tableView.reloadData()
        //        }
    }

    static func create(documentId: String, shouldShowDocument: Binding<Bool>) -> Self {
        Me.init(documentId: documentId, shouldShowDocument: shouldShowDocument)
    }
    
    static func create(documentId: String) -> some View {
        Me.init(documentId: documentId)
    }
}

extension EditorModule.Container.ViewRepresentable {
    class Coordinator {
        typealias Parent = EditorModule.Container.ViewRepresentable
        typealias IncomingAction = EditorModule.Container.ViewController.UserAction
        
        // MARK: Variables
        private var parent: Parent
        private var subscription: AnyCancellable?
        
        // MARK: Initialization
        init(_ parent: Parent) {
            self.parent = parent
        }
        
        /// Subscription
        func configured(userActionStream: AnyPublisher<IncomingAction, Never>) {
            self.subscription = userActionStream.sink(receiveValue: { [weak self] (value) in
                switch value {
                case .shouldDismiss: self?.dismiss()
                }
            })
        }
        
        /// Do dismiss
        func dismiss() {
            self.parent.shouldShowDocument.wrappedValue = false
        }
    }
}

