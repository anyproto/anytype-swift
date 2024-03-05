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
                relationValueModuleAssembly: self.modulesDI.relationValue(),
                newSearchModuleAssembly: self.modulesDI.newSearch(),
                analyticsType: analyticsType,
                toastPresenter: self.uiHelpersDI.toastPresenter(),
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                output: output
            )
        ).eraseToAnyView()
    }
}

