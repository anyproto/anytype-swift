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

fileprivate typealias Namespace = EditorModule.Document

extension Namespace {
    struct ViewRepresentable {
        @Environment(\.presentationMode) var presentationMode
        private(set) var documentId: String
    }
}

// MARK: - DocumentViewRepresentable
extension Namespace.ViewRepresentable: UIViewControllerRepresentable {
    
    private typealias ViewBuilder = Namespace.ViewBuilder
    typealias ViewController = EditorModule.Document.ViewController
    typealias Me = EditorModule.Document.ViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Me>) -> ViewController {
        /// Configure document view builder.
        let view = ViewBuilder.UIKitBuilder.view(by: .init(id: self.documentId))
                
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

extension Namespace.ViewRepresentable {
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
        func configured(headerViewModelPublisher: AnyPublisher<ViewController.HeaderView.UserAction, Never>?) -> Self {
            headerViewModelPublisher?.sink { [weak self] (value) in
                self?.processBackButtonPressed()
            }.store(in: &self.subscriptions)
            return self
        }
    }
}
