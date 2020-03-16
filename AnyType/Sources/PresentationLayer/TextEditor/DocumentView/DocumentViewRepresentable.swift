//
//  DocumentView+ViewController+Coordinator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

struct DocumentViewRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: DocumentViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) -> DocumentViewController {
        DocumentViewController().configured(self.viewModel)
    }
    
    func updateUIViewController(_ uiViewController: DocumentViewController, context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) {
        // our model did change?
        // should we do something?
        // well, we should calculate diffs.
        // But not now.
        // later.
        DispatchQueue.main.async {
            uiViewController.tableView?.tableView.reloadData()
        }
    }
}
