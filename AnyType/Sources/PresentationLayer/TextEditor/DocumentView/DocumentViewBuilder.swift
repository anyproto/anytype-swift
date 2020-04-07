//
//  DocumentViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

enum DocumentViewBuilder {
    struct Request {
        var id: String
        var useUIKit: Bool = true
    }
    
    static func documentView(by request: Request) -> some View {
        create(by: request)
    }
    
    // EXAMPLE:
    // Subscribe on viewModel.objectWillChange.
    // Even if it receive updates, it will not call UIViewControllerRepresentable method .updateController
    // It is nice exapmle of using UIViewControllerRepresentable.
    // Update controller not called. Ha.ha.ha.
    private static func create(by request: Request) -> AnyView {
        if request.useUIKit {
            let viewModel = DocumentViewModel(documentId: request.id, options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
            return .init(DocumentViewRepresentable.create(viewModel: viewModel))
        }
        let viewModel = Legacy_DocumentViewModel(documentId: request.id)
        return .init(Legacy_DocumentView(viewModel: viewModel))
    }
}
