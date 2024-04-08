import Foundation
import SwiftUI

@MainActor
protocol ServerConfigurationCoordinatorAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class ServerConfigurationCoordinatorAssembly: ServerConfigurationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    nonisolated init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - ServerConfigurationModuleAssemblyProtocol
    
    func make() -> AnyView {
        ServerConfigurationCoordinatorView(
            model: ServerConfigurationCoordinatorViewModel()
        ).eraseToAnyView()
    }
}
