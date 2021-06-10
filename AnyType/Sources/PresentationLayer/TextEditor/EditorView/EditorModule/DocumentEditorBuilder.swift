import Foundation
import UIKit
import SwiftUI
import Combine
import BlocksModels

enum DocumentEditorBuilder {
    
    static func build(id: BlockId) -> DocumentEditorViewController {
        let selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
        
        let editorViewModel = DocumentEditorViewModel(
            documentId: id,
            selectionHandler: selectionHandler
        )
        
        let editorController = DocumentEditorViewController(viewModel: editorViewModel)
        
        let router = DocumentViewCompoundRouter(
            viewController: editorController,
            userActionsStream: editorViewModel.publicUserActionPublisher
        )
        
        editorController.router = router
        
        editorViewModel.viewInput = editorController
        editorViewModel.editorRouter = EditorRouter(
            preseningViewController: editorController
        )
        
        return editorController
    }
    
}
