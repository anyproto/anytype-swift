import Foundation
import UIKit


class ServiceLocator {
    static let shared = ServiceLocator()
    
    private let services: [AnyObject] = [
        AppearanceService(),
        FirebaseService(),
        DeveloperOptionsService(),
        LocalRepoService(),
        KeychainStoreService(),
        ProfileService(),
        AuthService(
            localRepoService: LocalRepoService(),
            storeService: KeychainStoreService()
        )
    ]

    func resolve<T>() -> T {
        return services.first { service in
            return service is T
        } as! T
    }
}
