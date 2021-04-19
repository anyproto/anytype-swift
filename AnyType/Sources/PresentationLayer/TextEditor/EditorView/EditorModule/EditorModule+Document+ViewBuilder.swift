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

fileprivate typealias Namespace = EditorModule.Document

extension Namespace {
    enum ViewBuilder {
        struct Request {
            let id: String
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
        
        private enum Constants {
            static let selectedViewCornerRadius: CGFloat = 8
        }
        /// We define relationship between `Child` and `Self` components.
        /// Child component has a builder.
        ///
        /// In our case, we don't have builders and child components.
        /// This builder is a `leaf` of builders.
        ///
        /// For that, we define `ChildViewModel`, `ChildViewController`, `ChildViewBuilder` as `Void`.
        ///
        /// We don't have direct access to them, but we should an ability to add them to `SelfComponent` as `ChildComponent`.
        typealias ChildViewModel = Void
        typealias ChildViewController = Void
        typealias ChildViewBuilder = Void

        typealias ChildComponent = (viewController: ChildViewController, viewModel: ChildViewModel)
        typealias SelfComponent = (viewController: DocumentEditorViewController, viewModel: DocumentEditorViewModel, childComponent: ChildComponent)
        
        static func childComponent(by request: Request) -> ChildComponent {
            ((), ())
        }
        
        static func selfComponent(by request: Request) -> SelfComponent {
            let viewModel = DocumentEditorViewModel(documentId: request.id,
                                                    options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
            let viewCellFactory = DocumentViewCellFactory(selectedViewColor: .selectedItemColor,
                                                          selectedViewCornerRadius: Constants.selectedViewCornerRadius)
            let view: DocumentEditorViewController = .init(viewModel: viewModel, viewCellFactory: viewCellFactory)
            viewModel.viewInput = view
            
            return (view, viewModel, self.childComponent(by: request))
        }
        
        static func view(by request: Request) -> DocumentEditorViewController {
            self.selfComponent(by: request).0
        }
    }
}
