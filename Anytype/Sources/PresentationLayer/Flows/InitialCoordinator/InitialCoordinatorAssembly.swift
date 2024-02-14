import Foundation
import SwiftUI

@MainActor
protocol InitialCoordinatorAssemblyProtocol {
    func make() -> AnyView
}

@MainActor
final class InitialCoordinatorAssembly: InitialCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - InitialCoordinatorAssemblyProtocol
    
    func make() -> AnyView {
        InitialCoordinatorView(
            model: InitialCoordinatorViewModel(
                middlewareConfigurationProvider: self.serviceLocator.middlewareConfigurationProvider(),
                applicationStateService: self.serviceLocator.applicationStateService(),
                seedService: self.serviceLocator.seedService(),
                localAuthService: self.serviceLocator.localAuthService(),
                localRepoService: self.serviceLocator.localRepoService()
            )
        ).eraseToAnyView()
    }
}
