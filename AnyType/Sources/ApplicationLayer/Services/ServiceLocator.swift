import Foundation
import UIKit

class ServiceLocator: NSObject {
    //MARK: Shared
    static let shared: ServiceLocator = .init()
    
    private let services: [Setuppable] = [
        AppearanceService(),
        FirebaseService()
    ]

    func setup() {
        for service in services {
            service.setup()
        }
    }

    //MARK: Accessors
    func resolve<T>() -> T {
        return services.first { service in
            return service is T
        } as! T
    }
}
