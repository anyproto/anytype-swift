import Foundation
import SwiftUI

protocol DebugMenuModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class DebugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    @MainActor
    func make() -> AnyView {
        return DebugMenu(
            model: DebugMenuViewModel(
                debugService: self.serviceLocator.debugService(),
                localAuthService: self.serviceLocator.localAuthService(),
                localRepoService: self.serviceLocator.localRepoService(),
                authService: self.serviceLocator.authService(),
                applicationStateService: self.serviceLocator.applicationStateService()
            )
        ).eraseToAnyView()
    }
}
 
