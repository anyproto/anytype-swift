import Foundation
import UIKit


final class ServiceLocator {
    static let shared = ServiceLocator()
    
    // MARK: - Services
    
    func firebaseService() -> FirebaseService {
        FirebaseService()
    }
    
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
        AuthService(
            localRepoService: localRepoService(),
            seedService: seedService()
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
    
    // MARK: - Coodrdinators
    
    func applicationCoordinator(window: MainWindow) -> ApplicationCoordinator {
        ApplicationCoordinator(
            window: window,
            shakeHandler: ShakeHandler(window),
            authService: authService(),
            firebaseService: firebaseService(),
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
