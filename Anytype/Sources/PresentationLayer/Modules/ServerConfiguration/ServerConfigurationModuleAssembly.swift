import Foundation
import SwiftUI

@MainActor
protocol ServerConfigurationModuleAssemblyProtocol: AnyObject {
    func make(output: ServerConfigurationModuleOutput?) -> AnyView
}

final class ServerConfigurationModuleAssembly: ServerConfigurationModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ServerConfigurationModuleAssemblyProtocol
    
    func make(output: ServerConfigurationModuleOutput?) -> AnyView {
        ServerConfigurationView(
            model: ServerConfigurationViewModel(storage: self.serviceLocator.serverConfigurationStorage(), output: output)
        ).eraseToAnyView()
    }
}
