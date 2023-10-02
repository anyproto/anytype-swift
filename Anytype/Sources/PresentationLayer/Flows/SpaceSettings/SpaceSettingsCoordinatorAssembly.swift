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
                remoteStorageModuleAssembly: self.modulesDI.remoteStorage(),
                widgetObjectListModuleAssembly: self.modulesDI.widgetObjectList(),
                personalizationModuleAssembly: self.modulesDI.personalization(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                newSearchModuleAssembly: self.modulesDI.newSearch(),
                wallpaperPickerModuleAssembly: self.modulesDI.wallpaperPicker(),
                objectTypeProvider: self.serviceLocator.objectTypeProvider(),
                urlOpener: self.uiHelpersDI.urlOpener(),
                documentService: self.serviceLocator.documentService()
            )
        ).eraseToAnyView()
    }

}
