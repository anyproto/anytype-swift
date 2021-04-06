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
    
    /// creates new developerOptionsService
    func developerOptionsService() -> DeveloperOptionsService {
        DeveloperOptionsService()
    }
    
    /// creates new localRepoService
    func localRepoService() -> LocalRepoService {
        LocalRepoService()
    }
    
    /// creates new keychainStoreService
    func keychainStoreService() -> SecureStoreServiceProtocol {
        KeychainStoreService(
            keychainStore: KeychainStore()
        )
    }
    
    /// creates new profileService
    func profileService() -> ProfileService {
        ProfileService()
    }
    
    /// creates new authService
    func authService() -> AuthService {
        AuthService(
            localRepoService: localRepoService(),
            storeService: keychainStoreService()
        )
    }
    
    // MARK: - Coodrdinators
    /// creates new applicationCoordinator
    func applicationCoordinator(window: MainWindow) -> ApplicationCoordinator {
        ApplicationCoordinator(
            window: window,
            shakeHandler: ShakeHandler(window),
            developerOptionsService: developerOptionsService(),
            localRepoService: localRepoService(),
            authService: authService(),
            appearanceService: appearanceService(),
            firebaseService: firebaseService()
        )
    }
}
