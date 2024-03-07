import Foundation
import SwiftUI

protocol SelectRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        style: SelectRelationListStyle,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
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
        style: SelectRelationListStyle,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: SelectRelationListModuleOutput?
    ) -> AnyView {
        SelectRelationListView(
            viewModel: SelectRelationListViewModel(
                style: style,
                configuration: configuration,
                relationSelectedOptionsModel: RelationSelectedOptionsModel(
                    objectId: configuration.objectId,
                    selectionMode: configuration.selectionMode,
                    selectedOptionsIds: selectedOptionsIds,
                    relationKey: configuration.relationKey,
                    analyticsType: configuration.analyticsType,
                    relationsService: self.serviceLocator.relationService()
                ),
                searchService: self.serviceLocator.searchService(),
                output: output
            )
        )
        .eraseToAnyView()
    }
}
