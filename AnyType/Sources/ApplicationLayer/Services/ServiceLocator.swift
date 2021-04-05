import Foundation
import UIKit

class ServiceLocator: NSObject {
    //MARK: Shared
    static let shared: ServiceLocator = .init()
    
    private let services: [AnyObject] = [
        AppearanceService(),
        FirebaseService(),
        DeveloperOptionsService(),
        LocalRepoService()
    ]

    func setup() {
        for service in services {
            if let service = service as? Setuppable {
                service.setup()
            }
        }
    }

    //MARK: Accessors
    func resolve<T>() -> T {
        return services.first { service in
            return service is T
        } as! T
    }
}
