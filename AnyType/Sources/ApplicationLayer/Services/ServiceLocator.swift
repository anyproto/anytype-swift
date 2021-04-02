import Foundation
import UIKit

class ServiceLocator: NSObject {
    //MARK: Shared
    static let shared: ServiceLocator = .init()
    
    private let services: [ServicesSetupProtocol] = [
        AppearanceService(),
        FirebaseService()
    ]

    func setup() {
        for service in services as [ServicesSetupProtocol] {
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

extension ServiceLocator: UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) { }

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        setup()

        return true
    }
}
