import Foundation
import UIKit
import SwiftUI
import Combine
import BlocksModels

typealias EditorModuleContentModule = (
    viewController: EditorModuleContentViewController,
    selectionPresenter: EditorSelectionToolbarPresenter,
    publicUserActionPublisher: AnyPublisher<BlocksViews.UserAction, Never>
)

enum EditorModuleContentViewBuilder {
    static func сontent(id: String) -> EditorModuleContentModule {
        let bottomMenuViewController = BottomMenuViewController()
        
        let selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
        
        let presenter = EditorSelectionToolbarPresenter(
            bottomMenuViewController: bottomMenuViewController,
            selectionEventPublisher:selectionHandler.selectionEventPublisher()
        )
        
        let editorViewModel = DocumentEditorViewModel(
            documentId: id,
            selectionHandler: selectionHandler,
            selectionPresenter: presenter
        )
        
        let childViewController = DocumentEditorViewController(viewModel: editorViewModel, viewCellFactory: DocumentViewCellFactory())
        editorViewModel.viewInput = childViewController
        
        bottomMenuViewController.add(child: childViewController)
        
        let contentViewController = EditorModuleContentViewController(
            childViewController: bottomMenuViewController
        )
        
        return (contentViewController, presenter, editorViewModel.publicUserActionPublisher)
    }
}
