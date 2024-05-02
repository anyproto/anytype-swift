import SwiftUI
import Services
import AnytypeCore

protocol SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(with navigationContext: NavigationContextProtocol?) -> SetObjectCreationSettingsCoordinatorProtocol
}

final class SetObjectCreationSettingsCoordinatorAssembly: SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SetViewPickerCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with navigationContext: NavigationContextProtocol?) -> SetObjectCreationSettingsCoordinatorProtocol {
        SetObjectCreationSettingsCoordinator(
            navigationContext: navigationContext ?? uiHelpersDI.commonNavigationContext(),
            editorPageCoordinatorAssembly: coordinatorsDI.editorPage()
        )
    }
}
