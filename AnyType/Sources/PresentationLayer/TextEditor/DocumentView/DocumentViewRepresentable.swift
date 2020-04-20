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

struct DocumentViewRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DocumentViewModel
    private var router: DocumentViewRouting.CompoundRouter = .init()
    func makeCoordinator() -> Coordinator {
        DocumentViewRepresentable.Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) -> DocumentViewController {
        let view = DocumentViewController(viewModel: self.viewModel)
        
        /// Subscribe `router` on BlocksViewModels events from `All` blocks views models.
        let userActionPublisher = self.viewModel.$builders.map {
            $0.compactMap { $0 as? BlocksViews.Base.ViewModel }
        }
        .flatMap {
            Publishers.MergeMany($0.map{$0.userActionPublisher})
        }
        .eraseToAnyPublisher()
                
        _ = self.router.configured(userActionsStream: userActionPublisher)
        
        /// Subscribe `view controller` on events from `router`.
        view.subscribeOnRouting(self.router)

        view.delegate = context.coordinator

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
    class Coordinator: DocumentViewControllerDelegate {
        private var parent: DocumentViewRepresentable

        init(_ parent: DocumentViewRepresentable) {
            self.parent = parent
        }

        func didTapBackButton() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
