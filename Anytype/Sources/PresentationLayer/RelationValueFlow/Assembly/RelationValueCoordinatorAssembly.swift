import Foundation
import UIKit

final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(coordinatorsDI: CoordinatorsDIProtocol, modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make() -> RelationValueCoordinatorProtocol {
        
        let coordinator = RelationValueCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            relationValueModuleAssembly: modulesDI.relationValue(), 
            dateRelationCalendarModuleAssembly: modulesDI.dateRelationCalendar(), 
            selectRelationListCoordinatorAssembly: coordinatorsDI.selectRelationList(), 
            multiSelectRelationListCoordinatorAssembly: coordinatorsDI.multiSelectRelationList(),
            urlOpener: uiHelpersDI.urlOpener(),
            toastPresenter: uiHelpersDI.toastPresenter()
        )
        
        return coordinator
    }
    
}
