import Foundation
import SwiftUI

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    // TODO: Navigation: Delete it
    @MainActor
    func make() -> ApplicationCoordinatorProtocol
    
    @MainActor
    func makeView() -> AnyView
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
            authCoordinatorAssembly: coordinatorsDI.authorization(),
            homeWidgetsCoordinatorAssembly: coordinatorsDI.homeWidgets(),
            applicationStateService: serviceLocator.applicationStateService()
        )
        
        return ApplicationCoordinator(
            windowManager: windowManager,
            authService: serviceLocator.authService(),
            accountEventHandler: serviceLocator.accountEventHandler(),
            applicationStateService: serviceLocator.applicationStateService(),
            accountManager: serviceLocator.accountManager(),
            seedService: serviceLocator.seedService(),
            fileErrorEventHandler: serviceLocator.fileErrorEventHandler(),
            toastPresenter: uiHelpersDI.toastPresenter()
        )
    }
    
    @MainActor
    func makeView() -> AnyView {
        return ApplicationCoordinatorView(
            model: ApplicationCoordinatorViewModel(
                authService: self.serviceLocator.authService(),
                accountEventHandler: self.serviceLocator.accountEventHandler(),
                applicationStateService: self.serviceLocator.applicationStateService(),
                accountManager: self.serviceLocator.accountManager(),
                seedService: self.serviceLocator.seedService(),
                fileErrorEventHandler: self.serviceLocator.fileErrorEventHandler(),
                toastPresenter: self.uiHelpersDI.toastPresenter(),
                authCoordinatorAssembly: self.coordinatorsDI.authorization(),
                homeWidgetsCoordinatorAssembly: self.coordinatorsDI.homeWidgets()
            )
        ).eraseToAnyView()
    }
}
