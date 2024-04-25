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
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SpaceSettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SpaceSettingsCoordinatorView(
            model: SpaceSettingsCoordinatorViewModel(
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                widgetObjectListModuleAssembly: self.modulesDI.widgetObjectList(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                objectTypeSearchModuleAssembly: self.modulesDI.objectTypeSearch(),
                objectTypeProvider: self.serviceLocator.objectTypeProvider(),
                urlOpener: self.uiHelpersDI.urlOpener(),
                documentService: self.serviceLocator.documentService()
            )
        ).eraseToAnyView()
    }

}
