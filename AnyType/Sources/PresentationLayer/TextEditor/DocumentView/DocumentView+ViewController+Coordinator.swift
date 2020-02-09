//
//  DocumentView+ViewController+Coordinator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

extension DocumentView {
    struct ViewControllerContainer: UIViewControllerRepresentable {
        func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentView.ViewControllerContainer>) -> DocumentView.ViewController {
            DocumentView.ViewController.init().configured(self.viewModel)
        }
        
        func updateUIViewController(_ uiViewController: DocumentView.ViewController, context: UIViewControllerRepresentableContext<DocumentView.ViewControllerContainer>) {
            // our model did change?
            // should we do something?
            // well, we should calculate diffs.
            // But not now.
            // later.
            uiViewController.tableView?.tableView.reloadData()
        }
        
        typealias UIViewControllerType = DocumentView.ViewController
        typealias ViewModel = DocumentView.ViewModel
        
        @ObservedObject var viewModel: ViewModel
    }
}
