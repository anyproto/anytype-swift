//
//  DocumentModule+ContainerViewRepresentable.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    struct ContainerViewRepresentable {
        @Environment(\.presentationMode) var presentationMode
        private(set) var documentId: String
        private(set) var shouldShowDocument: Binding<Bool> = .init(get: { false }, set: { value in })
    }
}

// MARK: - ContentViewRepresentable
extension Namespace.ContainerViewRepresentable: UIViewControllerRepresentable {
    
    private typealias ViewBuilder = Namespace.ContainerViewBuilder
    typealias ViewController = DocumentModule.ContainerViewController
    typealias Me = DocumentModule.ContainerViewRepresentable
    
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

        let logger = Logging.createLogger(category: .todo(.improve("Discuss what we should do")))
        os_log(.debug, log: logger, "Do we need to reload table view data here?")
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

extension Namespace.ContainerViewRepresentable {
    class Coordinator {
        typealias Parent = DocumentModule.ContainerViewRepresentable
        typealias IncomingAction = DocumentModule.ContainerViewController.UserAction
        
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

