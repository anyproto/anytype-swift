import Foundation
import SwiftUI

protocol StatusRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedStatus: Relation.Status.Option?
    ) -> AnyView
}

final class StatusRelationListModuleAssembly: StatusRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - StatusRelationListModuleAssemblyProtocol
    
    @MainActor
    func make(objectId: String, configuration: RelationModuleConfiguration, selectedStatus: Relation.Status.Option?) -> AnyView {
        StatusRelationListView(
            viewModel: StatusRelationListViewModel(
                configuration: configuration,
                selectedStatus: selectedStatus,
                relationsService: self.serviceLocator.relationService(objectId: objectId),
                searchService: self.serviceLocator.searchService()
            )
        )
        .eraseToAnyView()
    }
}
