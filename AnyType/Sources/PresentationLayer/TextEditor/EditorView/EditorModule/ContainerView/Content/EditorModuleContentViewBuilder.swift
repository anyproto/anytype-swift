import Foundation
import UIKit
import SwiftUI
import Combine
import BlocksModels

typealias EditorModuleContentModule = (
    viewController: BottomMenuViewController,
    publicUserActionPublisher: AnyPublisher<BlocksViews.UserAction, Never>
)

enum EditorModuleContentViewBuilder {
    
    static func сontent(id: BlockId) -> EditorModuleContentModule {
        let bottomMenuController = BottomMenuViewController()
        
        let selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
        
        let editorViewModel = DocumentEditorViewModel(
            documentId: id,
            selectionHandler: selectionHandler
        )
        
        let editorController = DocumentEditorViewController(viewModel: editorViewModel)
        
        editorViewModel.viewInput = editorController
        editorViewModel.editorRouter = EditorRouter(
            preseningViewController: editorController
        )
        
        bottomMenuController.add(child: editorController)
        
        return (bottomMenuController, editorViewModel.publicUserActionPublisher)
    }
    
    
}
