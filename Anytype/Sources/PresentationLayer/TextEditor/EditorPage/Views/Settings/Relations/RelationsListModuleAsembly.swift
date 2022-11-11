import Foundation
import UIKit

protocol RelationsListModuleAssemblyProtocol {
 
    func make(document: BaseDocumentProtocol, router: EditorRouterProtocol) -> UIViewController
}

final class RelationsListModuleAssembly: RelationsListModuleAssemblyProtocol {
    
    // MARK: - RelationsListModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, router: EditorRouterProtocol) -> UIViewController {
        
        let viewModel = RelationsListViewModel(
            document: document,
            router: router,
            relationsService: RelationsService(objectId: document.objectId)
        )
        
        let view = RelationsListView(viewModel: viewModel)
        
        return AnytypePopup(contentView: view, popupLayout: .fullScreen)
    }
}
