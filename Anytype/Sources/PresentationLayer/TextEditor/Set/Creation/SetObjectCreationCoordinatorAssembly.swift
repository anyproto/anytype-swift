import Foundation
import UIKit
import SwiftUI

protocol SetObjectCreationCoordinatorAssemblyProtocol {
    func make() -> SetObjectCreationCoordinatorProtocol
}

final class SetObjectCreationCoordinatorAssembly: SetObjectCreationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SetObjectCreationCoordinatorAssemblyProtocol
    
    func make() -> SetObjectCreationCoordinatorProtocol {
        SetObjectCreationCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            toastPresenter: uiHelpersDI.toastPresenter(),
            createObjectModuleAssembly: modulesDI.createObject()
        )
    }
}
