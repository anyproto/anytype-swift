import Foundation
import SwiftUI
import Services

protocol RelationsListModuleAssemblyProtocol {
    @MainActor
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> AnyView
}

final class RelationsListModuleAssembly: RelationsListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RelationsListModuleAssemblyProtocol
    @MainActor
    func make(document: BaseDocumentProtocol, output: RelationsListModuleOutput) -> AnyView {
        RelationsListView(
            viewModel: RelationsListViewModel(
                document: document,
                relationsService: self.serviceLocator.relationService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
