import SwiftUI
import Services
import AnytypeCore

protocol SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(with navigationContext: NavigationContextProtocol?) -> SetObjectCreationSettingsCoordinator
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
    func make(with navigationContext: NavigationContextProtocol?) -> SetObjectCreationSettingsCoordinator {
        SetObjectCreationSettingsCoordinator(
            navigationContext: navigationContext ?? uiHelpersDI.commonNavigationContext(),
            setObjectCreationSettingsAssembly: modulesDI.setObjectCreationSettings(),
            editorAssembly: coordinatorsDI.editor(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: nil)
        )
    }
}
