import Foundation
import UIKit
import Services

protocol RelationsListModuleAssemblyProtocol {
    @MainActor
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> UIViewController
}

final class RelationsListModuleAssembly: RelationsListModuleAssemblyProtocol {
    
    // MARK: - RelationsListModuleAssemblyProtocol
    @MainActor
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
