import Foundation
import SwiftUI

protocol MultiSelectRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: MultiSelectRelationListModuleOutput?
    ) -> AnyView
}

final class MultiSelectRelationListModuleAssembly: MultiSelectRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - MultiSelectRelationListModuleAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: MultiSelectRelationListModuleOutput?
    ) -> AnyView {
        MultiSelectRelationListView(
            viewModel: MultiSelectRelationListViewModel(
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                output: output,
                relationsService: self.serviceLocator.relationService(objectId: objectId),
                searchService: self.serviceLocator.searchService()
            )
        ).eraseToAnyView()
    }
}
