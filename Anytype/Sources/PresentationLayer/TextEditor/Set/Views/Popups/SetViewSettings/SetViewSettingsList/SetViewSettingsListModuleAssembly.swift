import SwiftUI

protocol SetViewSettingsListModuleAssemblyProtocol {
    @MainActor
    func make(output: SetViewSettingsCoordinatorOutput?) -> AnyView
}

final class SetViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetViewSettingsListModuleAssemblyProtocol
    
    @MainActor
    func make(output: SetViewSettingsCoordinatorOutput?) -> AnyView {
        return SetViewSettingsList(
            model: SetViewSettingsListModel(output: output)
        ).eraseToAnyView()
    }
}
