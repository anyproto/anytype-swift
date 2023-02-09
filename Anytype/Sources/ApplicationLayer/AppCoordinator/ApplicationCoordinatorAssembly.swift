import Foundation

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> ApplicationCoordinatorProtocol
}

final class ApplicationCoordinatorAssembly: ApplicationCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - ApplicationCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> ApplicationCoordinatorProtocol {
        
        let windowManager = WindowManager(
            viewControllerProvider: uiHelpersDI.viewControllerProvider(),
            homeViewAssembly: coordinatorsDI.homeViewAssemby(),
            homeWidgetsCoordinatorAssembly: coordinatorsDI.homeWidgets(),
            applicationStateService: serviceLocator.applicationStateService()
        )
        
        return ApplicationCoordinator(
            windowManager: windowManager,
            authService: serviceLocator.authService(),
            accountEventHandler: serviceLocator.accountEventHandler(),
            applicationStateService: serviceLocator.applicationStateService(),
            accountManager: serviceLocator.accountManager()
        )
    }
}
