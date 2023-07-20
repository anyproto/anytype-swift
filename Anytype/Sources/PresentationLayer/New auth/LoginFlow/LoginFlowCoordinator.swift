import SwiftUI

@MainActor
protocol LoginFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class LoginFlowCoordinator: LoginFlowCoordinatorProtocol, LoginFlowOutput {
    
    // MARK: - DI
    
    private let loginViewModuleAssembly: LoginViewModuleAssemblyProtocol
    private let migrationGuideViewModuleAssembly: MigrationGuideViewModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    
    init(
        loginViewModuleAssembly: LoginViewModuleAssemblyProtocol,
        migrationGuideViewModuleAssembly: MigrationGuideViewModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol
    ) {
        self.loginViewModuleAssembly = loginViewModuleAssembly
        self.migrationGuideViewModuleAssembly = migrationGuideViewModuleAssembly
        self.navigationContext = navigationContext
    }
    
    // MARK: - LoginFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        loginViewModuleAssembly.make(output: self)
    }
    
    func onShowMigrationGuideAction() {
        let module = migrationGuideViewModuleAssembly.make()
        navigationContext.present(module)
    }
    
    func onSettingsAction() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
