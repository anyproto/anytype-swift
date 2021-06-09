import Foundation
import UIKit
import SwiftUI
import Combine
import BlocksModels

typealias EditorModuleContentModule = (
    viewController: DocumentEditorViewController,
    publicUserActionPublisher: AnyPublisher<BlocksViews.UserAction, Never>
)

enum EditorModuleContentViewBuilder {
    
    static func сontent(id: BlockId) -> EditorModuleContentModule {
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
        
        return (editorController, editorViewModel.publicUserActionPublisher)
    }
    
}
