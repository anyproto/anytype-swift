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


extension EditorModule.Document {
    struct ViewRepresentable {
        @Environment(\.presentationMode) var presentationMode
        private(set) var documentId: String
    }
}

// MARK: - DocumentViewRepresentable
extension EditorModule.Document.ViewRepresentable: UIViewControllerRepresentable {
    private typealias ViewBuilder = EditorModule.Document.ViewBuilder
    typealias Me = EditorModule.Document.ViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Me>) -> DocumentEditorViewController {
        /// Configure document view builder.
        let view = ViewBuilder.view(by: .init(id: self.documentId))
                
        /// Subscribe `coordinator` on events from `view.headerView`.
        _ = context.coordinator.configured(headerViewModelPublisher: view.headerViewModelPublisher)
        
        return view
    }
    
    func updateUIViewController(_ uiViewController: DocumentEditorViewController, context: UIViewControllerRepresentableContext<Me>) {
        // our model did change?
        // should we do something?
        // well, we should calculate diffs.
        // But not now.
        // later.

        assertionFailure("Discuss what we should do")
        // "Do we need to reload table view data here?"
        //        DispatchQueue.main.async {
        //            uiViewController.tableView?.tableView.reloadData()
        //        }
    }

    static func create(documentId: String) -> some View {
        Me.init(documentId: documentId)
    }
}

extension EditorModule.Document.ViewRepresentable {
    class Coordinator {
        typealias Parent = EditorModule.Document.ViewRepresentable
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
        func configured(headerViewModelPublisher: AnyPublisher<DocumentEditorHeaderView.UserAction, Never>?) -> Self {
            headerViewModelPublisher?.sink { [weak self] (value) in
                self?.processBackButtonPressed()
            }.store(in: &self.subscriptions)
            return self
        }
    }
}
