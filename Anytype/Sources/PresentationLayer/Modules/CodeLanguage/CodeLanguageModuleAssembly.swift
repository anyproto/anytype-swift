import Foundation
import UIKit
import Services
import SwiftUI

protocol CodeLanguageListModuleAssemblyProtocol {
    func makeLegacy(document: BaseDocumentProtocol, blockId: String) -> UIViewController
    func make(document: BaseDocumentProtocol, blockId: String, selectedLanguage: CodeLanguage) -> AnyView
}

final class CodeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - CodeLanguageListModuleAssemblyProtocol
    
    func makeLegacy(document: BaseDocumentProtocol, blockId: String) -> UIViewController {
        let viewModel = CodeLanguageLegacyListViewModel(
            document: document,
            blockId: blockId,
            blockService: serviceLocator.blockService()
        )
        return CodeLanguageLegacyListViewController(viewModel: viewModel)
    }
    
    func make(document: BaseDocumentProtocol, blockId: String, selectedLanguage: CodeLanguage) -> AnyView {
        return CodeLanguageListView(
            model: CodeLanguageListViewModel(
                document: document,
                blockId: blockId,
                selectedLanguage: selectedLanguage,
                blockService: serviceLocator.blockService()
            )
        ).eraseToAnyView()
    }
}
