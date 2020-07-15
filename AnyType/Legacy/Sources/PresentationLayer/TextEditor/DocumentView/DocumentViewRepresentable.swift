//
//  DocumentView+ViewController+Coordinator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

// MARK: - DocumentViewRepresentable
struct DocumentViewRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    private(set) var documentId: String
    
    func makeCoordinator() -> Coordinator {
        DocumentViewRepresentable.Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) -> DocumentViewController {
        /// Configure document view builder.
        let view = DocumentViewBuilder.UIKitBuilder.documentView(by: .init(id: self.documentId, useUIKit: true))
                
        /// Subscribe `coordinator` on events from `view.headerView`.
        _ = context.coordinator.configured(headerViewModelPublisher: view.headerViewModelPublisher)
        
        return view
    }
    
    func updateUIViewController(_ uiViewController: DocumentViewController, context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) {
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

    static func create(documentId: String) -> some View {
        DocumentViewRepresentable.init(documentId: documentId)
    }
}

extension DocumentViewRepresentable {
    class Coordinator {
        // MARK: Variables
        private var parent: DocumentViewRepresentable
        private var subscriptions: Set<AnyCancellable> = .init()

        // MARK: Initialization
        init(_ parent: DocumentViewRepresentable) {
            self.parent = parent
        }

        // MARK: Actions
        func processBackButtonPressed() {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // MARK: Configuration
        func configured(headerViewModelPublisher: AnyPublisher<DocumentViewController.HeaderView.UserAction, Never>) -> Self {
            headerViewModelPublisher.sink { [weak self] (value) in
                self?.processBackButtonPressed()
            }.store(in: &self.subscriptions)
            return self
        }
    }
}
