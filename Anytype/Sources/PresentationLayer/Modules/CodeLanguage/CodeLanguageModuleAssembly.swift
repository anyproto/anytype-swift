import Foundation
import UIKit
import BlocksModels

protocol CodeLanguageListModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol, blockId: BlockId) -> UIViewController
}

final class CodeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - CodeLanguageListModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, blockId: BlockId) -> UIViewController {
        let viewModel = CodeLanguageListViewModel(
            document: document,
            blockId: blockId,
            blockListService: serviceLocator.blockListService(documentId: document.objectId)
        )
        return CodeLanguageListViewController(viewModel: viewModel)
    }
}
