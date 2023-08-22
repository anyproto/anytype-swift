import SwiftUI

protocol SetViewSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView
}

final class SetViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetViewSettingsCoordinatorModuleAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView {
        return SetViewSettingsCoordinatorView(
            model: SetViewSettingsCoordinatorViewModel(
                setDocument: setDocument,
                setViewSettingsListModuleAssembly: self.modulesDI.setViewSettingsList(),
                setSortsListCoordinatorAssembly: self.coordinatorsDI.setSortsList()
            )
        ).eraseToAnyView()
    }
}
