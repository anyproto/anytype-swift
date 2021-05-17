import Foundation
import UIKit
import SwiftUI
import Combine
import BlocksModels

typealias EditorModuleContentModule = (
    viewController: EditorModuleContentViewController,
    viewModel: EditorModuleContentViewModel,
    publicUserActionPublisher: AnyPublisher<BlocksViews.UserAction, Never>
)

enum EditorModuleContentViewBuilder {
    static func сontent(id: String) -> EditorModuleContentModule {
        let bottomMenuViewController = BottomMenuViewController()
        
        let contentViewModel = EditorModuleContentViewModel(
            bottomMenuViewController: bottomMenuViewController
        )
        
        let editorViewModel = DocumentEditorViewModel(
            documentId: id,
            selectionHandler: contentViewModel.selectionHandler,
            multiSelectionUserActionPublisher: contentViewModel.selectionAction
        )
        
        let childViewController = DocumentEditorViewController(viewModel: editorViewModel, viewCellFactory: DocumentViewCellFactory())
        editorViewModel.viewInput = childViewController
        
        bottomMenuViewController.add(child: childViewController)
        
        let contentViewController = EditorModuleContentViewController(
            viewModel: contentViewModel,
            childViewController: bottomMenuViewController
        )
        
        return (contentViewController, contentViewModel, editorViewModel.publicUserActionPublisher)
    }
}
