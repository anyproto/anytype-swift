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
            localRepoService: localRepoService(),
            authService: authService(),
            firebaseService: firebaseService(),
            authAssembly: authAssembly()
        )
    }
    
    func homeCoordinator() -> HomeCoordinator {
        HomeCoordinator(
            settingsAssembly: settingsAssembly(),
            editorAssembly: editorAssembly()
        )
    }
    
    // MARK: - Assembly
    func authAssembly() -> AuthAssembly {
        AuthAssembly()
    }
    
    func settingsAssembly() -> SettingsAssembly {
        SettingsAssembly()
    }
    
    func editorAssembly() -> EditorAssembly {
        EditorAssembly()
    }
}
