import Foundation
import SwiftUI

protocol ObjectSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        output: ObjectSettingsCoordinatorOutput?
    ) -> AnyView
}

final class ObjectSettingsCoordinatorAssembly: ObjectSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectSettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        output: ObjectSettingsCoordinatorOutput?
    ) -> AnyView {
        ObjectSettingsCoordinatorView(
            model: ObjectSettingsCoordinatorViewModel(
                objectId: objectId,
                output: output,
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                relationsListCoordinatorAssembly: self.coordinatorsDI.relationsList(),
                newSearchModuleAssembly: self.modulesDI.newSearch()
            )
        ).eraseToAnyView()
    }
}
