import Foundation
import UIKit


class ServiceLocator {
    static let shared: ServiceLocator = .init()
    
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

    func setup() {
        for service in services {
            if let service = service as? Setuppable {
                service.setup()
            }
        }
    }

    func resolve<T>() -> T {
        return services.first { service in
            return service is T
        } as! T
    }
}
