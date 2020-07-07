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
        fileprivate typealias CurrentViewRepresentable = Namespace.ContentViewRepresentable
        static func documentView(by request: Request) -> some View {
            self.create(by: request)
        }
        
        private static func create(by request: Request) -> AnyView {
            .init(CurrentViewRepresentable.create(documentId: request.documentRequest.id))
        }
    }
}

extension Namespace.ContentViewBuilder {
    enum UIKitBuilder {
        typealias ViewModel = DocumentModule.ContentViewController.ViewModel
        typealias ViewController = DocumentModule.ContentViewController
        
        typealias ChildViewModel = DocumentModule.DocumentViewModel
        typealias ChildViewController = DocumentModule.DocumentViewController
        typealias ChildViewBuilder = DocumentModule.DocumentViewBuilder
        
        typealias ChildComponent = (ChildViewController, ChildViewModel)
        typealias SelfComponent = (ViewController, ViewModel, ChildComponent)
        
        /// Returns concrete child View of a Document.
        /// It is configured to show exactly one document or be a part of Container.
        ///
        static func childComponent(by request: Request) -> ChildComponent {
            let viewModel: ChildViewModel = .init(documentId: request.documentRequest.id, options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
            let view: ChildViewController = .init(viewModel: viewModel)
            return (view, viewModel)
        }
        
        /// Returns concrete Document.
        /// It is configured to show exactly one document or be a part of Container.
        ///
        static func selfComponent(by request: Request) -> SelfComponent {
            let (childViewController, childViewModel) = self.childComponent(by: request)
            let viewModel: ViewModel = .init()
            
            let topBottomMenuViewController: Namespace.TopBottomMenuViewController = .init()
            topBottomMenuViewController.add(child: childViewController)
            _ = viewModel.configured(topBottomMenuViewController: topBottomMenuViewController)
            
            let viewController: ViewController = .init(viewModel: viewModel)
                        
            _ = viewController.configured(childViewController: topBottomMenuViewController)

            /// Configure DocumentViewModel
            /// We must set publishers...
            _ = childViewModel.configured(multiSelectionUserActionPublisher: viewModel.selectionAction)
            _ = childViewModel.configured(selectionHandler: viewModel.selectionHandler)
            
            /// Do not forget to configure routers events...
            
            return (viewController, viewModel, (childViewController, childViewModel))
        }
        
        static func view(by request: Request) -> ViewController {
            self.selfComponent(by: request).0
        }
    }
}
