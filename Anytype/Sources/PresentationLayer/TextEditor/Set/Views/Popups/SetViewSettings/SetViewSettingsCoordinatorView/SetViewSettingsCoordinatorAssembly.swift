import SwiftUI

protocol SetViewSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class SetViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetViewSettingsCoordinatorModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SetViewSettingsCoordinatorView(
            model: SetViewSettingsCoordinatorViewModel(
                setViewSettingsListModuleAssembly: self.modulesDI.setViewSettingsList()
            )
        ).eraseToAnyView()
    }
}
