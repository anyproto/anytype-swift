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
    
    nonisolated init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
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
                dateRelationCalendarModuleAssembly: self.modulesDI.dateRelationCalendar(),
                selectRelationListCoordinatorAssembly: self.coordinatorsID.selectRelationList(),
                objectRelationListCoordinatorAssembly: self.coordinatorsID.objectRelationList(),
                analyticsType: analyticsType,
                output: output
            )
        ).eraseToAnyView()
    }
}

