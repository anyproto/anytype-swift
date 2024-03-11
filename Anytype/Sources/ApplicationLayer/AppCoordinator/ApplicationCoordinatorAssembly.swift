import Foundation
import SwiftUI

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func makeView() -> AnyView
}

final class ApplicationCoordinatorAssembly: ApplicationCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let modulesDI: ModulesDIProtocol

    init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        modulesDI: ModulesDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
        self.modulesDI = modulesDI
    }
    
    // MARK: - ApplicationCoordinatorAssemblyProtocol
    
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
                authCoordinatorAssembly: self.coordinatorsDI.authorization(),
                homeCoordinatorAssembly: self.coordinatorsDI.home(),
                deleteAccountModuleAssembly: self.modulesDI.deleteAccount(),
                initialCoordinatorAssembly: self.coordinatorsDI.initial(), 
                navigationContext: self.uiHelpersDI.commonNavigationContext()
            )
        ).eraseToAnyView()
    }
}
