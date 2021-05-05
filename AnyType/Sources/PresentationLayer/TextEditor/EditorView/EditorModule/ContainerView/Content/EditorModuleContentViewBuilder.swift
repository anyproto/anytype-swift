import Foundation
import UIKit
import SwiftUI


enum EditorModuleContentViewBuilder {
    /// Middleware builder.
    /// It is between `ContainerViewBuilder` and `DocumentViewBuilder`.
    ///
    /// It has a `ChildComponent` from `DocumentViewBuilder.UIKitBuilder.SelfComponent`
    /// And it provides `SelfComponent` to `ContainerViewBuilder` as `ContainerViewBuilder.UIKitBuilder.ChildComponent`
    ///
    
    typealias ChildViewBuilder = EditorModuleDocumentViewBuilder
    
    typealias ChildComponent = ChildViewBuilder.SelfComponent
    typealias SelfComponent = (viewController: EditorModuleContentViewController, viewModel: EditorModuleContentViewModel, childComponent: ChildComponent)
    
    /// Returns concrete child View of a Document.
    /// It is configured to show exactly one document or be a part of Container.
    ///
    static func childComponent(id: String) -> ChildComponent {
        ChildViewBuilder.selfComponent(id: id)
    }
    
    /// Returns concrete Document.
    /// It is configured to show exactly one document or be a part of Container.
    ///
    static func selfComponent(id: String) -> SelfComponent {
        let (childViewController, childViewModel) = self.childComponent(id: id)
        let viewModel = EditorModuleContentViewModel()
        
        let topBottomMenuViewController: TopBottomMenuViewController = .init()
        topBottomMenuViewController.add(child: childViewController)
        _ = viewModel.configured(topBottomMenuViewController: topBottomMenuViewController)
        
        let viewController: EditorModuleContentViewController = .init(viewModel: viewModel)
                    
        _ = viewController.configured(childViewController: topBottomMenuViewController)

        /// Configure DocumentViewModel
        /// We must set publishers...
        _ = childViewModel.configured(multiSelectionUserActionPublisher: viewModel.selectionAction)
        _ = childViewModel.configured(selectionHandler: viewModel.selectionHandler)
        
        /// Do not forget to configure routers events...
        
        return (viewController, viewModel, (childViewController, childViewModel))
    }
    
    static func view(id: String) -> EditorModuleContentViewController {
        self.selfComponent(id: id).0
    }
}
