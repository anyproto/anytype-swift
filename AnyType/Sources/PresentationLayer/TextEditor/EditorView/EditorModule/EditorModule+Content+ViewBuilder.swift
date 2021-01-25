//
//  EditorModule+Content+ViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

fileprivate typealias Namespace = EditorModule.Content

extension Namespace {
    enum ViewBuilder {
        struct Request {
            var documentRequest: EditorModule.Document.ViewBuilder.Request
        }
    }
}

extension Namespace.ViewBuilder {
    enum SwiftUIBuilder {
        fileprivate typealias CurrentViewRepresentable = Namespace.ViewRepresentable
        static func documentView(by request: Request) -> some View {
            self.create(by: request)
        }
        
        private static func create(by request: Request) -> AnyView {
            .init(CurrentViewRepresentable.create(documentId: request.documentRequest.id))
        }
    }
}

extension Namespace.ViewBuilder {
    enum UIKitBuilder {
        /// Middleware builder.
        /// It is between `ContainerViewBuilder` and `DocumentViewBuilder`.
        ///
        /// It has a `ChildComponent` from `DocumentViewBuilder.UIKitBuilder.SelfComponent`
        /// And it provides `SelfComponent` to `ContainerViewBuilder` as `ContainerViewBuilder.UIKitBuilder.ChildComponent`
        ///
        typealias ViewModel = EditorModule.Content.ViewController.ViewModel
        typealias ViewController = EditorModule.Content.ViewController
        
        typealias ChildViewModel = EditorModule.Document.ViewController.ViewModel
        typealias ChildViewController = EditorModule.Document.ViewController
        typealias ChildViewBuilder = EditorModule.Document.ViewBuilder
        
        typealias ChildComponent = ChildViewBuilder.UIKitBuilder.SelfComponent
        typealias SelfComponent = (viewController: ViewController, viewModel: ViewModel, childComponent: ChildComponent)
        
        /// Returns concrete child View of a Document.
        /// It is configured to show exactly one document or be a part of Container.
        ///
        static func childComponent(by request: Request) -> ChildComponent {
            ChildViewBuilder.UIKitBuilder.selfComponent(by: request.documentRequest)
        }
        
        /// Returns concrete Document.
        /// It is configured to show exactly one document or be a part of Container.
        ///
        static func selfComponent(by request: Request) -> SelfComponent {
            let (childViewController, childViewModel, childChildComponent) = self.childComponent(by: request)
            let viewModel: ViewModel = .init()
            
            let topBottomMenuViewController: EditorModule.TopBottomMenuViewController = .init()
            topBottomMenuViewController.add(child: childViewController)
            _ = viewModel.configured(topBottomMenuViewController: topBottomMenuViewController)
            
            let viewController: ViewController = .init(viewModel: viewModel)
                        
            _ = viewController.configured(childViewController: topBottomMenuViewController)

            /// Configure DocumentViewModel
            /// We must set publishers...
            _ = childViewModel.configured(multiSelectionUserActionPublisher: viewModel.selectionAction)
            _ = childViewModel.configured(selectionHandler: viewModel.selectionHandler)
            
            /// Do not forget to configure routers events...
            
            return (viewController, viewModel, (childViewController, childViewModel, childChildComponent))
        }
        
        static func view(by request: Request) -> ViewController {
            self.selfComponent(by: request).0
        }
    }
}
