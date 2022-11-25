import Foundation
import UIKit

protocol RelationsListModuleAssemblyProtocol {
 
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> UIViewController
}

final class RelationsListModuleAssembly: RelationsListModuleAssemblyProtocol {
    
    // MARK: - RelationsListModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> UIViewController {
        
        let viewModel = RelationsListViewModel(
            document: document,
            relationsService: RelationsService(objectId: document.objectId),
            output: output
        )
        
        let view = RelationsListView(viewModel: viewModel)
        
        return AnytypePopup(contentView: view, popupLayout: .fullScreen)
    }
}
