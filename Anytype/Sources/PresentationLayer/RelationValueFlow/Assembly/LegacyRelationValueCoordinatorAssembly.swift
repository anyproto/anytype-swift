import Foundation
import UIKit

@MainActor
final class LegacyRelationValueCoordinatorAssembly: LegacyRelationValueCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make() -> LegacyRelationValueCoordinatorProtocol {
        
        let coordinator = LegacyRelationValueCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            relationValueModuleAssembly: modulesDI.relationValue(),
            urlOpener: uiHelpersDI.urlOpener()
        )
        
        return coordinator
    }
    
}
