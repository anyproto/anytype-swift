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
        let topBottomMenuViewController = TopBottomMenuViewController()
        
        let contentViewModel = EditorModuleContentViewModel(
            topBottomMenuViewController: topBottomMenuViewController
        )
        
        let editorViewModel = DocumentEditorViewModel(
            documentId: id,
            selectionHandler: contentViewModel.selectionHandler,
            multiSelectionUserActionPublisher: contentViewModel.selectionAction
        )
        
        let childViewController = DocumentEditorViewController(viewModel: editorViewModel, viewCellFactory: DocumentViewCellFactory())
        editorViewModel.viewInput = childViewController
        
        topBottomMenuViewController.add(child: childViewController)
        
        let contentViewController = EditorModuleContentViewController(
            viewModel: contentViewModel,
            childViewController: topBottomMenuViewController
        )
        
        return (contentViewController, contentViewModel, editorViewModel.publicUserActionPublisher)
    }
}
