import Foundation
import UIKit
import Services

protocol RelationsListModuleAssemblyProtocol {
    @MainActor
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> UIViewController
}

final class RelationsListModuleAssembly: RelationsListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RelationsListModuleAssemblyProtocol
    @MainActor
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> UIViewController {
        
        let viewModel = RelationsListViewModel(
            document: document,
            relationsService: serviceLocator.relationService(),
            output: output
        )
        
        let view = RelationsListView(viewModel: viewModel)
        
        return AnytypePopup(contentView: view, popupLayout: .fullScreen)
    }
}
