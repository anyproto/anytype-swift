import Foundation
import SwiftUI

protocol ObjectRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        limitedObjectTypes: [String],
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) -> AnyView
}

final class ObjectRelationListModuleAssembly: ObjectRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectRelationListModuleAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        limitedObjectTypes: [String],
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) -> AnyView {
        ObjectRelationListView(
            viewModel: ObjectRelationListViewModel(
                limitedObjectTypes: limitedObjectTypes,
                configuration: configuration,
                relationSelectedOptionsModel: RelationSelectedOptionsModel(
                    selectionMode: configuration.selectionMode,
                    selectedOptionsIds: selectedOptionsIds,
                    relationKey: configuration.relationKey,
                    analyticsType: configuration.analyticsType,
                    relationsService: self.serviceLocator.relationService(objectId: objectId)
                ),
                searchService: self.serviceLocator.searchService(), 
                objectTypeProvider: self.serviceLocator.objectTypeProvider(), 
                objectActionsService: self.serviceLocator.objectActionsService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
