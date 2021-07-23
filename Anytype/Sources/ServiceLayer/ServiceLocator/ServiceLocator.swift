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
        SeedService(
            keychainStore: KeychainStore()
        )
    }
    
    /// creates new authService
    func authService() -> AuthServiceProtocol {
        let service = seedService()
        return AuthService(
            localRepoService: localRepoService(),
            seedService: service,
            loginStateService: LoginStateService(seedService: service)
        )
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
