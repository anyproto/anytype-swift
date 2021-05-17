import Foundation
import UIKit
import SwiftUI

enum EditorModuleContentViewBuilder {
    typealias SelfComponent = (
        viewController: EditorModuleContentViewController,
        viewModel: EditorModuleContentViewModel,
        childComponent: EditorComponent
    )
    
    /// Returns concrete Document.
    /// It is configured to show exactly one document or be a part of Container.
    ///
    static func selfComponent(id: String) -> SelfComponent {
        let (childViewController, childViewModel) = editorModule(id: id)
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
    
    private static let selectedViewCornerRadius: CGFloat = 8
    typealias EditorComponent = (viewController: DocumentEditorViewController, viewModel: DocumentEditorViewModel)
    static func editorModule(id: String) -> EditorComponent {
        let viewModel = DocumentEditorViewModel(documentId: id)
        let viewCellFactory = DocumentViewCellFactory(
            selectedViewColor: .selectedItemColor,
            selectedViewCornerRadius: selectedViewCornerRadius
        )
        let view = DocumentEditorViewController(viewModel: viewModel, viewCellFactory: viewCellFactory)
        viewModel.viewInput = view
        
        return (view, viewModel)
    }
}
