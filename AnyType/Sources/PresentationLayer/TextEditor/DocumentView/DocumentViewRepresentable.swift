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


// MARK: - Publishers
extension DocumentViewRepresentable {
    func userActionPublisher() -> AnyPublisher<BlocksViews.UserAction, Never> {
        /// Subscribe `router` on BlocksViewModels events from `All` blocks views models.

        self.viewModel.$builders.map {
            $0.compactMap { $0 as? BlocksViews.Base.ViewModel }
        }
        .flatMap {
            Publishers.MergeMany($0.map{$0.userActionPublisher})
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - DocumentViewRepresentable
struct DocumentViewRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DocumentViewModel
    func makeCoordinator() -> Coordinator {
        DocumentViewRepresentable.Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) -> DocumentViewController {
        let view = DocumentViewController(viewModel: self.viewModel)
        
        /// Subscribe `router` on BlocksViewModels events from `All` blocks views models.
        let userActionPublisher = self.userActionPublisher()
        
        let router = context.coordinator.router
        _ = router.configured(userActionsStream: userActionPublisher)
        
        /// Subscribe `view controller` on events from `router`.
        view.subscribeOnRouting(router)
        
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

    static func create(viewModel: DocumentViewModel) -> some View {
        DocumentViewRepresentable.init(viewModel: viewModel)
    }
}

extension DocumentViewRepresentable {
    class Coordinator {
        // MARK: Variables
        private var parent: DocumentViewRepresentable
        private(set) var router: DocumentViewRouting.CompoundRouter = .init()
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
