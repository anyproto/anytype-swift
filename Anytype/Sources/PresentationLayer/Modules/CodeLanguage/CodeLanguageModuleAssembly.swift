import Foundation
import UIKit
import Services
import SwiftUI

protocol CodeLanguageListModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol, blockId: String, selectedLanguage: CodeLanguage) -> AnyView
}

final class CodeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - CodeLanguageListModuleAssemblyProtocol
    
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
