import Foundation

protocol CreateWidgetCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> CreateWidgetCoordinatorProtocol
}

final class CreateWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol {
    
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
    
    // MARK: - CreateWidgetCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> CreateWidgetCoordinatorProtocol {
        return CreateWidgetCoordinator(
            newSearchModuleAssembly: modulesDI.newSearch,
            navigationContext: uiHelpersDI.commonNavigationContext,
            blockWidgetService: serviceLocator.blockWidgetService()
        )
    }
}
