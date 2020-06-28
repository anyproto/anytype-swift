//
//  DocumentViewBuilder+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    enum DocumentViewBuilder {
        struct Request {
            var id: String
//            var useUIKit: Bool = true
        }
    }
}

extension Namespace.DocumentViewBuilder {
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
            .init(Namespace.DocumentViewRepresentable.create(documentId: request.id))
        }
    }
}

extension Namespace.DocumentViewBuilder {
    enum UIKitBuilder {
        private typealias ViewModel = Namespace.DocumentViewModel
        typealias ViewController = DocumentModule.DocumentViewController
        
        static func documentView(by request: Request) -> ViewController {
            let viewModel: ViewModel = .init(documentId: request.id, options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
            
            let view: ViewController = .init(viewModel: viewModel)
            
            /// Subscribe `router` on BlocksViewModels events from `All` blocks views models.
            
            let router: DocumentViewRouting.CompoundRouter = .init()
            /// TODO: Remove later.
            /// Lets keep it for a while, until we completely remove old document view model.
            ///
//            let publisher = viewModel.soloUserActionPublisherPublisher
//            _ = router.configured(userActionsStreamStream: publisher)
            _ = router.configured(userActionsStream: viewModel.soloUserActionPublisher)
            
            /// Subscribe `view controller` on events from `router`.
            view.subscribeOnRouting(router)
            return view
        }
    }
}
