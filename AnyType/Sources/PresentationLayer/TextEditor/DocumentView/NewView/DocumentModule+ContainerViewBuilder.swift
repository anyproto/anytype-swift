//
//  DocumentModule+ContainerViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    enum ContainerViewBuilder {
        struct Request {
            typealias Id = String            
            var id: Id
            
            fileprivate var documentRequest: DocumentModule.ContentViewBuilder.Request {
                .init(documentRequest: .init(id: self.id))
            }
        }
    }
}

extension Namespace.ContainerViewBuilder {
    enum SwiftUIBuilder {
        private typealias CurrentViewRepresentable = Namespace.ContainerViewRepresentable
        private static func create(by request: Request) -> AnyView {
            .init(CurrentViewRepresentable.create(documentId: request.id))
        }
        
        private static func create(by request: Request, shouldShowDocument: Binding<Bool>) -> AnyView {
            .init(CurrentViewRepresentable.create(documentId: request.id, shouldShowDocument: shouldShowDocument))
        }

        static func documentView(by request: Request) -> some View {
            self.create(by: request)
        }
        
        static func documentView(by request: Request, shouldShowDocument: Binding<Bool>) -> some View {
            self.create(by: request, shouldShowDocument: shouldShowDocument)
        }
    }
}

extension Namespace.ContainerViewBuilder {
    enum UIKitBuilder {
        typealias ViewModel = DocumentModule.ContainerViewController.ViewModel
        typealias ViewController = DocumentModule.ContainerViewController
        
        typealias ChildViewModel = DocumentModule.ContentViewController.ViewModel
        typealias ChildViewController = DocumentModule.ContentViewController
        typealias ChildViewBuilder = DocumentModule.ContentViewBuilder
        
        typealias ChildComponent = ChildViewBuilder.UIKitBuilder.SelfComponent
        typealias SelfComponent = (ViewController, ViewModel, ChildComponent)
        
        static func childComponent(by request: Request) -> ChildComponent {
            ChildViewBuilder.UIKitBuilder.selfComponent(by: request.documentRequest)
        }
        
        static func selfComponent(by request: Request) -> SelfComponent {
            let childComponent = self.childComponent(by: request)
            
            let childViewController = childComponent.0
            
            /// Configure Navigation Controller
            let navigationController: UINavigationController = .init(navigationBarClass: Namespace.ContainerViewBuilder.NavigationBar.self, toolbarClass: nil)
            NavigationBar.applyAppearance()
            navigationController.setViewControllers([childViewController], animated: false)
            
            /// Configure Navigation Item for Content View Model.
            /// We need it to support Selection navigation bar buttons.
            let childViewModel = childComponent.1
            _ = childViewModel.configured(navigationItem: childViewController.navigationItem)
            
            let childChildComponent = childComponent.2
            let childChildViewModel = childChildComponent.1
            
            /// Don't forget configure router by events from blocks.
            let router: DocumentViewRouting.CompoundRouter = .init()
            _ = router.configured(userActionsStream: childChildViewModel.soloUserActionPublisher)
            
            /// Configure ViewModel of current View Controller.
            let viewModel: ViewModel = .init()
            _ = viewModel.configured(router: router)
            
            /// Configure current ViewController.
            let viewController: ViewController = .init(viewModel: viewModel)
            _ = viewController.configured(childViewController: navigationController)
            
            /// Configure navigation item of root
            childViewController.navigationItem.leftBarButtonItem = .init(title: "Dismiss", style: .plain, target: viewController, action: #selector(viewController.dismissAction))
            
            /// DEBUG: Conformance to navigation delegate.
            ///
            navigationController.delegate = viewController
            
            return (viewController, viewModel, childComponent)
        }
        
        static func view(by request: Request) -> ViewController {
            self.selfComponent(by: request).0
        }
    }
}

// MARK: Custom Appearance
/// TODO: Move it somewhere
private extension Namespace.ContainerViewBuilder {
    class NavigationBar: UINavigationBar {
        static func applyAppearance() {
            let appearance = Self.appearance()
            appearance.prefersLargeTitles = false
            appearance.tintColor = .orange
            appearance.backgroundColor = .white
        }
    }
}
