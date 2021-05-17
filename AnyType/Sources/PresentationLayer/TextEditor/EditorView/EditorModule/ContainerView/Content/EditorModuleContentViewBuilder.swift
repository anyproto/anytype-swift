import Foundation
import UIKit
import SwiftUI

enum EditorModuleContentViewBuilder {
    typealias SelfComponent = (
        viewController: EditorModuleContentViewController,
        viewModel: EditorModuleContentViewModel,
        childComponent: EditorComponent
    )
    
    static func selfComponent(id: String) -> SelfComponent {
        let (childViewController, childViewModel) = editorModule(id: id)
        
        let topBottomMenuViewController = TopBottomMenuViewController()
        topBottomMenuViewController.add(child: childViewController)
        
        let viewModel = EditorModuleContentViewModel(
            topBottomMenuViewController: topBottomMenuViewController
        )
        
        let viewController: EditorModuleContentViewController = .init(viewModel: viewModel)
                    
        _ = viewController.configured(childViewController: topBottomMenuViewController)

        _ = childViewModel.configured(multiSelectionUserActionPublisher: viewModel.selectionAction)
        _ = childViewModel.configured(selectionHandler: viewModel.selectionHandler)
        
        return (viewController, viewModel, (childViewController, childViewModel))
    }
    
    typealias EditorComponent = (viewController: DocumentEditorViewController, viewModel: DocumentEditorViewModel)
    static func editorModule(id: String) -> EditorComponent {
        let viewModel = DocumentEditorViewModel(documentId: id)
        let cellFactory = DocumentViewCellFactory()
        let view = DocumentEditorViewController(viewModel: viewModel, viewCellFactory: cellFactory)
        viewModel.viewInput = view
        
        return (view, viewModel)
    }
}
