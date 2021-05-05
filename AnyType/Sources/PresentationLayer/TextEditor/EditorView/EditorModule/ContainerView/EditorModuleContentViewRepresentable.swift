import Foundation
import SwiftUI
import Combine
import os



struct EditorModuleContentViewRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    private(set) var documentId: String
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<EditorModuleContentViewRepresentable>) -> EditorModuleContentViewController {
        /// Configure document view builder.
//        let view = ViewBuilder.UIKitBuilder.documentView(by: .init(id: self.documentId))
        let view = EditorModuleContentViewBuilder.UIKitBuilder.view(by: .init(documentRequest: .init(id: self.documentId)))
        
        // TODO: Fix later.
        // We should enable back button handling.
        /// Subscribe `coordinator` on events from `view.headerView`.
        /// TODO: Add back button here.
//        _ = context.coordinator.configured(headerViewModelPublisher: view.headerViewModelPublisher)
        
        return view
    }
    
    func updateUIViewController(_ uiViewController: EditorModuleContentViewController, context: UIViewControllerRepresentableContext<EditorModuleContentViewRepresentable>) {
        // our model did change?
        // should we do something?
        // well, we should calculate diffs.
        // But not now.
        // later.

        assertionFailure("Discuss what we should do")
        // "Do we need to reload table view data here?")
        //        DispatchQueue.main.async {
        //            uiViewController.tableView?.tableView.reloadData()
        //        }
    }

    static func create(documentId: String) -> some View {
        EditorModuleContentViewRepresentable(documentId: documentId)
    }
}

extension EditorModuleContentViewRepresentable {
    class Coordinator {
        // MARK: Variables
        private var parent: EditorModuleContentViewRepresentable
        private var subscriptions: Set<AnyCancellable> = .init()

        // MARK: Initialization
        init(_ parent: EditorModuleContentViewRepresentable) {
            self.parent = parent
        }

        // MARK: Actions
//        func processBackButtonPressed() {
//            parent.presentationMode.wrappedValue.dismiss()
//        }
        
        // MARK: Configuration
//        func configured(headerViewModelPublisher: AnyPublisher<ViewController.HeaderView.UserAction, Never>) -> Self {
//            headerViewModelPublisher.sink { [weak self] (value) in
//                self?.processBackButtonPressed()
//            }.store(in: &self.subscriptions)
//            return self
//        }
    }
}
