import Foundation
import UIKit


final class ServiceLocator {
    static let shared = ServiceLocator()
    
    // MARK: - Services
    
    /// creates new localRepoService
    func localRepoService() -> LocalRepoServiceProtocol {
        LocalRepoService()
    }
    
    func seedService() -> SeedServiceProtocol {
        SeedService(keychainStore: KeychainStore())
    }
    
    /// creates new authService
    func authService() -> AuthServiceProtocol {
        return AuthService(
            localRepoService: localRepoService(),
            seedService: seedService(),
            loginStateService: loginStateService()
        )
    }
    
    func loginStateService() -> LoginStateService {
        LoginStateService(seedService: seedService())
    }
    
    func dashboardService() -> DashboardServiceProtocol {
        DashboardService()
    }
    
    func blockActionsServiceSingle() -> BlockActionsServiceSingleProtocol {
        BlockActionsServiceSingle()
    }
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        ObjectActionsService()
    }
    
    func fileService() -> BlockActionsServiceFileProtocol {
        BlockActionsServiceFile()
    }
    
    func searchService() -> SearchService {
        SearchService()
    }
    
    // MARK: - Coodrdinators
    
    func applicationCoordinator(window: MainWindow) -> ApplicationCoordinator {
        ApplicationCoordinator(
            window: window,
            authService: authService(),
            authAssembly: AuthAssembly()
        )
    }
    
    func homeCoordinator() -> HomeCoordinator {
        HomeCoordinator(
            settingsAssembly: SettingsAssembly(),
            editorAssembly:  EditorAssembly()
        )
    }

}
