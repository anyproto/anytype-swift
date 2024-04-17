import Foundation
import SwiftUI

protocol ObjectSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void
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
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void
    ) -> AnyView {
        ObjectSettingsCoordinatorView(
            model: ObjectSettingsCoordinatorViewModel(
                objectId: objectId,
                output: output,
                objectSettingsHandler: objectSettingsHandler,
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                objectLayoutPickerModuleAssembly: self.modulesDI.objectLayoutPicker(),
                objectIconPickerModuleAssembly: self.modulesDI.objectIconPicker(),
                relationsListCoordinatorAssembly: self.coordinatorsDI.relationsList(),
                newSearchModuleAssembly: self.modulesDI.newSearch()
            )
        ).eraseToAnyView()
    }
}
