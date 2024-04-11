import SwiftUI
import Services
import AnytypeCore

protocol SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(with navigationContext: NavigationContextProtocol?) -> SetObjectCreationSettingsCoordinatorProtocol
}

final class SetObjectCreationSettingsCoordinatorAssembly: SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SetViewPickerCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with navigationContext: NavigationContextProtocol?) -> SetObjectCreationSettingsCoordinatorProtocol {
        SetObjectCreationSettingsCoordinator(
            navigationContext: navigationContext ?? uiHelpersDI.commonNavigationContext(),
            setObjectCreationSettingsAssembly: modulesDI.setObjectCreationSettings(),
            objectTypeSearchModuleAssembly: modulesDI.objectTypeSearch(),
            editorPageCoordinatorAssembly: coordinatorsDI.editorPage()
        )
    }
}
