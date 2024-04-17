import Services
import UIKit

@MainActor
protocol ObjectSettingModuleAssemblyProtocol {
    func make(
        objectId: String,
        output: ObjectSettingsModelOutput,
        actionHandler: @escaping (ObjectSettingsAction) -> Void
    ) -> UIViewController
}

@MainActor
final class ObjectSettingModuleAssembly: ObjectSettingModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectSettingModuleAssemblyProtocol
    
    func make(
        objectId: String,
        output: ObjectSettingsModelOutput,
        actionHandler: @escaping (ObjectSettingsAction) -> Void
    ) -> UIViewController {
        let viewModel = ObjectSettingsViewModel(
            objectId: objectId,
            output: output,
            settingsActionHandler: actionHandler
        )
        let view = ObjectSettingsView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: view, floatingPanelStyle: true)
        
        return popup
    }
}
