import Foundation
import UIKit

@MainActor
final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    nonisolated init(coordinatorsDI: CoordinatorsDIProtocol, modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make() -> RelationValueCoordinatorProtocol {
        
        let coordinator = RelationValueCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            relationValueModuleAssembly: modulesDI.relationValue(), 
            dateRelationCalendarModuleAssembly: modulesDI.dateRelationCalendar(), 
            selectRelationListCoordinatorAssembly: coordinatorsDI.selectRelationList(), 
            objectRelationListCoordinatorAssembly: coordinatorsDI.objectRelationList(),
            urlOpener: uiHelpersDI.urlOpener(),
            toastPresenter: uiHelpersDI.toastPresenter(),
            relationsService: serviceLocator.relationService()
        )
        
        return coordinator
    }
    
}
