import Foundation
import SwiftUI

protocol SelectRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionId: String?,
        output: SelectRelationListModuleOutput?
    ) -> AnyView
}

final class SelectRelationListModuleAssembly: SelectRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SelectRelationListModuleAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionId: String?,
        output: SelectRelationListModuleOutput?
    ) -> AnyView {
        SelectRelationListView(
            viewModel: SelectRelationListViewModel(
                configuration: configuration,
                selectedOptionId: selectedOptionId,
                output: output,
                relationsService: self.serviceLocator.relationService(objectId: objectId),
                searchService: self.serviceLocator.searchService()
            )
        )
        .eraseToAnyView()
    }
}
