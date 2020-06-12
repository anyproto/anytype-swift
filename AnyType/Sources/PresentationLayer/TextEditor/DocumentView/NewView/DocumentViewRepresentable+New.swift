//
//  DocumentViewRepresentable+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    struct DocumentViewRepresentable {
        @Environment(\.presentationMode) var presentationMode
        private(set) var documentId: String
    }
}

// MARK: - DocumentViewRepresentable
extension Namespace.DocumentViewRepresentable: UIViewControllerRepresentable {
    
    private typealias ViewBuilder = Namespace.DocumentViewBuilder
    typealias ViewController = DocumentModule.DocumentViewController
    typealias Me = DocumentModule.DocumentViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Me>) -> ViewController {
        /// Configure document view builder.
        let view = ViewBuilder.UIKitBuilder.documentView(by: .init(id: self.documentId))
                
        /// Subscribe `coordinator` on events from `view.headerView`.
        _ = context.coordinator.configured(headerViewModelPublisher: view.headerViewModelPublisher)
        
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

    static func create(documentId: String) -> some View {
        DocumentViewRepresentable.init(documentId: documentId)
    }
}

extension Namespace.DocumentViewRepresentable {
    class Coordinator {
        typealias Parent = DocumentModule.DocumentViewRepresentable
        // MARK: Variables
        private var parent: Parent
        private var subscriptions: Set<AnyCancellable> = .init()

        // MARK: Initialization
        init(_ parent: Parent) {
            self.parent = parent
        }

        // MARK: Actions
        func processBackButtonPressed() {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // MARK: Configuration
        func configured(headerViewModelPublisher: AnyPublisher<ViewController.HeaderView.UserAction, Never>) -> Self {
            headerViewModelPublisher.sink { [weak self] (value) in
                self?.processBackButtonPressed()
            }.store(in: &self.subscriptions)
            return self
        }
    }
}
