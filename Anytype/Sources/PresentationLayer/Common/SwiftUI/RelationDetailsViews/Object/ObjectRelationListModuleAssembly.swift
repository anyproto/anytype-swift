import Foundation
import SwiftUI

@MainActor
protocol ObjectRelationListModuleAssemblyProtocol: AnyObject {
    func makeObjectModule(
        objectId: String,
        limitedObjectTypes: [String],
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) -> AnyView
    
    func makeFileModule(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) -> AnyView
}

@MainActor
final class ObjectRelationListModuleAssembly: ObjectRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectRelationListModuleAssemblyProtocol
    
    
    func makeObjectModule(
        objectId: String,
        limitedObjectTypes: [String],
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) -> AnyView {
        ObjectRelationListView(
            viewModel: ObjectRelationListViewModel(
                configuration: configuration, 
                interactor: ObjectRelationListInteractor(
                    spaceId: configuration.spaceId,
                    limitedObjectTypes: limitedObjectTypes,
                    objectTypeProvider: self.serviceLocator.objectTypeProvider(),
                    searchService: self.serviceLocator.searchService()
                ),
                relationSelectedOptionsModel: RelationSelectedOptionsModel(
                    objectId: objectId,
                    selectionMode: configuration.selectionMode,
                    selectedOptionsIds: selectedOptionsIds,
                    relationKey: configuration.relationKey,
                    analyticsType: configuration.analyticsType,
                    relationsService: self.serviceLocator.relationService()
                ),
                objectActionsService: self.serviceLocator.objectActionsService(),
                output: output
            )
        ).eraseToAnyView()
    }
    
    func makeFileModule(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) -> AnyView {
        ObjectRelationListView(
            viewModel: ObjectRelationListViewModel(
                configuration: configuration,
                interactor: FileRelationListInteractor(
                    spaceId: configuration.spaceId,
                    searchService: self.serviceLocator.searchService()
                ),
                relationSelectedOptionsModel: RelationSelectedOptionsModel(
                    objectId: objectId,
                    selectionMode: configuration.selectionMode,
                    selectedOptionsIds: selectedOptionsIds,
                    relationKey: configuration.relationKey,
                    analyticsType: configuration.analyticsType,
                    relationsService: self.serviceLocator.relationService()
                ),
                objectActionsService: self.serviceLocator.objectActionsService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
