//
//  DocumentView+ViewController+Coordinator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import os

struct DocumentViewRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: DocumentViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) -> DocumentViewController {
        DocumentViewController(viewModel: self.viewModel)
    }
    
    func updateUIViewController(_ uiViewController: DocumentViewController, context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) {
        // our model did change?
        // should we do something?
        // well, we should calculate diffs.
        // But not now.
        // later.
        
        let logger = Logging.createLogger(category: .todo(.improve("Discuss what we should do")))
        os_log(.debug, log: logger, "Do we need reload table view data here?")
//        DispatchQueue.main.async {
//            uiViewController.tableView?.tableView.reloadData()
//        }
    }
    
    static func create(viewModel: DocumentViewModel) -> some View {
        DocumentViewRepresentable.init(viewModel: viewModel)
    }
}
