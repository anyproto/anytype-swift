import Foundation
import UIKit
import SwiftUI
import Combine
import BlocksModels

typealias EditorModuleContentModule = (
    viewController: BottomMenuViewController,
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
        
        let childViewController = DocumentEditorViewController(viewModel: editorViewModel)
        editorViewModel.viewInput = childViewController
        
        bottomMenuViewController.add(child: childViewController)
        
        return (bottomMenuViewController, presenter, editorViewModel.publicUserActionPublisher)
    }
}
