import Foundation
import UIKit

final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make() -> RelationValueCoordinatorProtocol {
        
        let coordinator = RelationValueCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            relationValueModuleAssembly: modulesDI.relationValue(), 
            dateRelationCalendarModuleAssembly: modulesDI.dateRelationCalendar(), 
            relationContainerModuleAssembly: modulesDI.relationContainer(),
            urlOpener: uiHelpersDI.urlOpener()
        )
        
        return coordinator
    }
    
}
