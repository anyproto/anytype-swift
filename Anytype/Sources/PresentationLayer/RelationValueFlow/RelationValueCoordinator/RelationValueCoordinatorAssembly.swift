import Foundation
import SwiftUI
import Services

@MainActor
protocol RelationValueCoordinatorAssemblyProtocol {
    func make(
        relation: Relation,
        objectDetails: ObjectDetails,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput?
    ) -> AnyView
}

@MainActor
final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - EditorSetCoordinatorAssemblyProtocol
    
    func make(
        relation: Relation,
        objectDetails: ObjectDetails,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput?
    ) -> AnyView {
        RelationValueCoordinatorView(
            model: RelationValueCoordinatorViewModel(
                relation: relation,
                objectDetails: objectDetails,
                objectRelationListCoordinatorAssembly: self.coordinatorsID.objectRelationList(), 
                textRelationEditingModuleAssembly: self.modulesDI.textRelationEditing(), 
                urlOpener: self.uiHelpersDI.urlOpener(),
                analyticsType: analyticsType,
                output: output
            )
        ).eraseToAnyView()
    }
}

