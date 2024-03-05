import Foundation
import SwiftUI
import Services

@MainActor
protocol RelationsListCoordinatorAssemblyProtocol {
    func make(document: BaseDocumentProtocol, output: RelationValueCoordinatorOutput?) -> AnyView
}

@MainActor
final class RelationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - EditorSetCoordinatorAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, output: RelationValueCoordinatorOutput?) -> AnyView {
        RelationsListCoordinatorView(
            model: RelationsListCoordinatorViewModel(
                document: document,
                relationsListModuleAssembly: self.modulesDI.relationsList(),
                relationValueCoordinatorAssembly: self.coordinatorsID.relationValue(),
                addNewRelationCoordinator: self.coordinatorsID.addNewRelation().make(), 
                legacyRelationValueCoordinator: self.coordinatorsID.legacyRelationValue().make(),
                output: output
            )
        ).eraseToAnyView()
    }
}

