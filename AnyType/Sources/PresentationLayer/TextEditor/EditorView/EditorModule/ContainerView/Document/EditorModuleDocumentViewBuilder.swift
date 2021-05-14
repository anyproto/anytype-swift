import Foundation
import SwiftUI
import Combine


enum EditorModuleDocumentViewBuilder {
    private static let selectedViewCornerRadius: CGFloat = 8
    
    typealias SelfComponent = (viewController: DocumentEditorViewController, viewModel: DocumentEditorViewModel)
    
    
    static func editorModule(id: String) -> SelfComponent {
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
