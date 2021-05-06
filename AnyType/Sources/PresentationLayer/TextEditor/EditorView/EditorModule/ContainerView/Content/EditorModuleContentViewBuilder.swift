import Foundation
import UIKit
import SwiftUI

/// This builder in between `ContainerViewBuilder` and `DocumentViewBuilder`.
enum EditorModuleContentViewBuilder {
    typealias ChildComponent = EditorModuleDocumentViewBuilder.SelfComponent
    typealias SelfComponent = (viewController: EditorModuleContentViewController, viewModel: EditorModuleContentViewModel, childComponent: ChildComponent)
    
    /// Returns concrete Document.
    /// It is configured to show exactly one document or be a part of Container.
    ///
    static func selfComponent(id: String) -> SelfComponent {
        let (childViewController, childViewModel) = EditorModuleDocumentViewBuilder.editorModule(id: id)
        let viewModel = EditorModuleContentViewModel()
        
        let topBottomMenuViewController = TopBottomMenuViewController()
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
}
