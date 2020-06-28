//
//  DocumentModule+ContentViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    enum ContentViewBuilder {
        struct Request {
            var documentRequest: DocumentModule.DocumentViewBuilder.Request
        }
    }
}

extension Namespace.ContentViewBuilder {
    enum SwiftUIBuilder {
        static func documentView(by request: Request) -> some View {
            self.create(by: request)
        }
        
        private static func create(by request: Request) -> AnyView {
            .init(Namespace.ContentViewRepresentable.create(documentId: request.documentRequest.id))
        }
    }
}

extension Namespace.ContentViewBuilder {
    enum UIKitBuilder {
        private typealias ViewModel = Namespace.ContentViewController.ViewModel
        typealias ViewController = DocumentModule.ContentViewController
        
        private typealias DocumentViewModel = Namespace.DocumentViewModel
        private typealias DocumentViewController = Namespace.DocumentViewController
        private typealias DocumentViewBuilder = Namespace.DocumentViewBuilder
                
        private static func documentView(by request: Request) -> (DocumentViewController, DocumentViewModel, DocumentViewRoutingOutputProtocol) {
            
            let viewModel: DocumentViewModel = .init(documentId: request.documentRequest.id, options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))

            let view: DocumentViewController = .init(viewModel: viewModel)

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
            return (view, viewModel, router)
        }
        
        static func view(by request: Request) -> ViewController {
            let (documentView, documentViewModel, router) = self.documentView(by: request)
            let viewModel: ViewModel = .init()
            _ = viewModel.configured(router: router)
            
            let topBottomMenuViewController: Namespace.TopBottomMenuViewController = .init()
            topBottomMenuViewController.add(child: documentView)
            _ = viewModel.configured(topBottomMenuViewController: topBottomMenuViewController)
            
            let viewController: ViewController = .init(viewModel: viewModel)
            _ = viewController.configured(childViewController: topBottomMenuViewController)

            // Configure DocumentViewModel
            // We must set publishers...
            _ = documentViewModel.configured(multiSelectionUserActionPublisher: viewModel.selectionAction)
            _ = documentViewModel.configured(selectionHandler: viewModel.selectionHandler)
            
            return viewController
        }
    }
}
