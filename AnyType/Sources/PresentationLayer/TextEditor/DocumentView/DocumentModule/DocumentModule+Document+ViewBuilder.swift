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

fileprivate typealias Namespace = DocumentModule.Document

extension Namespace {
    enum ViewBuilder {
        struct Request {
            var id: String
//            var useUIKit: Bool = true
        }
    }
}

extension Namespace.ViewBuilder {
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
            .init(Namespace.ViewRepresentable.create(documentId: request.id))
        }
    }
}

extension Namespace.ViewBuilder {
    enum UIKitBuilder {
        /// Interesting part.
        /// We define relationship between `Child` and `Self` components.
        /// Child component has a builder.
        ///
        /// In our case, we don't have builders and child components.
        /// This builder is a `leaf` of builders.
        ///
        /// For that, we define `ChildViewModel`, `ChildViewController`, `ChildViewBuilder` as `Void`.
        ///
        /// We don't have direct access to them, but we should an ability to add them to `SelfComponent` as `ChildComponent`.
        ///
        typealias ViewModel = DocumentModule.Document.ViewController.ViewModel
        typealias ViewController = DocumentModule.Document.ViewController
        
        typealias ChildViewModel = Void
        typealias ChildViewController = Void
        typealias ChildViewBuilder = Void

        typealias ChildComponent = (ChildViewController, ChildViewModel)
        typealias SelfComponent = (ViewController, ViewModel, ChildComponent)
        
        static func childComponent(by request: Request) -> ChildComponent {
            ((), ())
        }
        
        static func selfComponent(by request: Request) -> SelfComponent {
            let viewModel: ViewModel = .init(documentId: request.id, options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
            let view: ViewController = .init(viewModel: viewModel)
            return (view, viewModel, self.childComponent(by: request))
        }
        
        static func documentView(by request: Request) -> ViewController {
            self.selfComponent(by: request).0
        }
    }
}
