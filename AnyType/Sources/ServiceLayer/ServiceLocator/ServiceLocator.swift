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
    
    /// creates new keychainStoreService
    func keychainStoreService() -> SecureStoreServiceProtocol {
        KeychainStoreService(
            keychainStore: KeychainStore()
        )
    }
    
    /// creates new authService
    func authService() -> AuthServiceProtocol {
        AuthService(
            localRepoService: localRepoService(),
            storeService: keychainStoreService()
        )
    }
    
    func dashboardService() -> DashboardServiceProtocol {
        DashboardService()
    }
    
    func blockActionsServiceSingle() -> BlockActionsServiceSingleProtocol {
        BlockActionsServiceSingle()
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
