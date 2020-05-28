//
//  DocumentViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum DocumentViewBuilder {
    struct Request {
        var id: String
        var useUIKit: Bool = true
    }
}

extension DocumentViewBuilder {
    enum SwiftUIBuilder {
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
                return .init(DocumentViewRepresentable.create(documentId: request.id))
            }
            let viewModel = Legacy_DocumentViewModel(documentId: request.id)
            return .init(Legacy_DocumentView(viewModel: viewModel))
        }
    }
}

extension DocumentViewBuilder {
    enum UIKitBuilder {
        static func documentView(by request: Request) -> DocumentViewController {
            if request.useUIKit {
                let viewModel: DocumentViewModel = .init(documentId: request.id, options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
                
                let view: DocumentViewController = .init(viewModel: viewModel)
                
                /// Subscribe `router` on BlocksViewModels events from `All` blocks views models.
    
                let router: DocumentViewRouting.CompoundRouter = .init()
                let publisher = viewModel.userActionPublisher
                _ = router.configured(userActionsStreamStream: publisher)
                
                /// Subscribe `view controller` on events from `router`.
                view.subscribeOnRouting(router)
                return view
            }
            
            fatalError("We can't create viewController in SwiftUI request.")
        }
    }
}
