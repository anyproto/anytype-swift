import Foundation
import UIKit


final class ServiceLocator {
    static let shared = ServiceLocator()
    
    // MARK: - Services
    /// creates new appearanceService
    func appearanceService() -> AppearanceService {
        AppearanceService()
    }
    
    /// creates new firebaseService
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
            appearanceService: appearanceService(),
            firebaseService: firebaseService(),
            authAssembly: authAssembly()
        )
    }
    
    func homeCoordinator() -> OldHomeCoordinator {
        OldHomeCoordinator(
            profileAssembly: self.profileAssembly(),
            editorAssembly: self.editorAssembly()
        )
    }
    
    // MARK: - Assembly
    func authAssembly() -> AuthAssembly {
        AuthAssembly()
    }
    
    func profileAssembly() -> ProfileAssembly {
        ProfileAssembly()
    }
    
    func editorAssembly() -> EditorAssembly {
        EditorAssembly()
    }
}
