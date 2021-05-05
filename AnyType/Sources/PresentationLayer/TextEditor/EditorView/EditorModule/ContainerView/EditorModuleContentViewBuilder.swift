import Foundation
import UIKit
import SwiftUI


enum EditorModuleContentViewBuilder {
    struct Request {
        var documentRequest: EditorModule.Document.ViewBuilder.Request
    }

    enum SwiftUIBuilder {
        static func documentView(by request: Request) -> some View {
            self.create(by: request)
        }
        
        private static func create(by request: Request) -> AnyView {
            .init(EditorModuleContentViewRepresentable.create(documentId: request.documentRequest.id))
        }
    }

    enum UIKitBuilder {
        /// Middleware builder.
        /// It is between `ContainerViewBuilder` and `DocumentViewBuilder`.
        ///
        /// It has a `ChildComponent` from `DocumentViewBuilder.UIKitBuilder.SelfComponent`
        /// And it provides `SelfComponent` to `ContainerViewBuilder` as `ContainerViewBuilder.UIKitBuilder.ChildComponent`
        ///
        
//        typealias ChildViewModel = EditorModule.Document.ViewController.ViewModel
//        typealias ChildViewController = EditorModule.Document.ViewController
        typealias ChildViewBuilder = EditorModule.Document.ViewBuilder
        
        typealias ChildComponent = ChildViewBuilder.UIKitBuilder.SelfComponent
        typealias SelfComponent = (viewController: EditorModuleContentViewController, viewModel: EditorModuleContentViewModel, childComponent: ChildComponent)
        
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
            let viewModel = EditorModuleContentViewModel()
            
            let topBottomMenuViewController: EditorModule.TopBottomMenuViewController = .init()
            topBottomMenuViewController.add(child: childViewController)
            _ = viewModel.configured(topBottomMenuViewController: topBottomMenuViewController)
            
            let viewController: EditorModuleContentViewController = .init(viewModel: viewModel)
                        
            _ = viewController.configured(childViewController: topBottomMenuViewController)

            /// Configure DocumentViewModel
            /// We must set publishers...
            _ = childViewModel.configured(multiSelectionUserActionPublisher: viewModel.selectionAction)
            _ = childViewModel.configured(selectionHandler: viewModel.selectionHandler)
            
            /// Do not forget to configure routers events...
            
            return (viewController, viewModel, (childViewController, childViewModel, childChildComponent))
        }
        
        static func view(by request: Request) -> EditorModuleContentViewController {
            self.selfComponent(by: request).0
        }
    }
}
