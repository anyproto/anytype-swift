import Foundation
import UIKit
import SwiftUI

protocol SetObjectCreationCoordinatorAssemblyProtocol {
    func make(
        objectId: String,
        blockId: String?
    ) -> SetObjectCreationCoordinatorProtocol
}

final class SetObjectCreationCoordinatorAssembly: SetObjectCreationCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetObjectCreationCoordinatorAssemblyProtocol
    
    func make(
        objectId: String,
        blockId: String?
    ) -> SetObjectCreationCoordinatorProtocol {
        SetObjectCreationCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            toastPresenter: uiHelpersDI.toastPresenter(),
            objectCreationHelper: serviceLocator.setObjectCreationHelper(objectId: objectId, blockId: blockId),
            createObjectModuleAssembly: modulesDI.createObject()
        )
    }
}

extension SetObjectCreationCoordinatorAssemblyProtocol {
    func make(objectId: String) -> SetObjectCreationCoordinatorProtocol {
        make(objectId: objectId, blockId: nil)
    }
}
