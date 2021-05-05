import Foundation
import SwiftUI
import Combine


enum EditorModuleDocumentViewBuilder {
    private enum Constants {
        static let selectedViewCornerRadius: CGFloat = 8
    }
    
    typealias SelfComponent = (viewController: DocumentEditorViewController, viewModel: DocumentEditorViewModel)
    
    
    static func selfComponent(id: String) -> SelfComponent {
        let viewModel = DocumentEditorViewModel(
            documentId: id,
            options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true)
        )
        let viewCellFactory = DocumentViewCellFactory(selectedViewColor: .selectedItemColor,
                                                      selectedViewCornerRadius: Constants.selectedViewCornerRadius)
        let view: DocumentEditorViewController = .init(viewModel: viewModel, viewCellFactory: viewCellFactory)
        viewModel.viewInput = view
        
        return (view, viewModel)
    }
    
    static func view(id: String) -> DocumentEditorViewController {
        self.selfComponent(id: id).0
    }
}
