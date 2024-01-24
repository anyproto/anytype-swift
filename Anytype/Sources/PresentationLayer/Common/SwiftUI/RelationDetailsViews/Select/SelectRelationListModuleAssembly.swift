import Foundation
import SwiftUI

protocol SelectRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?
    ) -> AnyView
}

final class SelectRelationListModuleAssembly: SelectRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SelectRelationListModuleAssemblyProtocol
    
    @MainActor
    func make(objectId: String, configuration: RelationModuleConfiguration, selectedOption: SelectRelationOption?) -> AnyView {
        SelectRelationListView(
            viewModel: SelectRelationListViewModel(
                configuration: configuration,
                selectedOption: selectedOption,
                relationsService: self.serviceLocator.relationService(objectId: objectId),
                searchService: self.serviceLocator.searchService()
            )
        )
        .eraseToAnyView()
    }
}
