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
                relationSelectedOptionsModel: RelationSelectedOptionsModel(
                    mode: .single,
                    selectedOptionsIds: [selectedOptionId].compactMap { $0 },
                    relationKey: configuration.relationKey,
                    analyticsType: configuration.analyticsType,
                    relationsService: self.serviceLocator.relationService(objectId: objectId)
                ),
                searchService: self.serviceLocator.searchService(),
                output: output
            )
        )
        .eraseToAnyView()
    }
}
