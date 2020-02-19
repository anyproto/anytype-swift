//
//  DocumentView+Factory.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

extension DocumentView {
    // EXAMPLE:
    // Subscribe on viewModel.objectWillChange.
    // Even if it receive updates, it will not call UIViewControllerRepresentable method .updateController
    // It is nice exapmle of using UIViewControllerRepresentable.
    // Update controller not called. Ha.ha.ha.
    
    static func create(viewModel: DocumentViewModel) -> AnyView {
        if let viewModel = viewModel as? DocumentView.ViewModel {
            return .init(DocumentView.ViewControllerContainer(viewModel: viewModel))
        }
        else {
            return .init(DocumentView(viewModel: viewModel))
        }
    }
}
