import Foundation
import SwiftUI

protocol SpaceSettingsCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class SpaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SpaceSettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SpaceSettingsCoordinatorView(
            model: SpaceSettingsCoordinatorViewModel(
                spaceSettingsModuleAssembly: self.modulesDI.spaceSettings(),
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                objectIconPickerModuleAssembly: self.modulesDI.objectIconPicker(),
                documentService: self.serviceLocator.documentService()
            )
        ).eraseToAnyView()
    }

}
