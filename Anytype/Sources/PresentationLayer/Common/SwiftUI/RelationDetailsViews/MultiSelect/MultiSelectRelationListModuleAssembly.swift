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
                relationSelectedOptionsModel: RelationSelectedOptionsModel(
                    mode: .multi,
                    selectedOptionsIds: selectedOptionsIds,
                    relationKey: configuration.relationKey,
                    analyticsType: configuration.analyticsType,
                    relationsService: self.serviceLocator.relationService(objectId: objectId)
                ),
                searchService: self.serviceLocator.searchService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
