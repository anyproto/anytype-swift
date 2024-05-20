import SwiftUI
import Services
import AnytypeCore

protocol SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> SetObjectCreationSettingsCoordinatorProtocol
}

final class SetObjectCreationSettingsCoordinatorAssembly: SetObjectCreationSettingsCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetViewPickerCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> SetObjectCreationSettingsCoordinatorProtocol {
        SetObjectCreationSettingsCoordinator(
            editorPageCoordinatorAssembly: coordinatorsDI.editorPage()
        )
    }
}
