import Foundation
import SwiftUI

@MainActor
protocol ServerDocumentPickerModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class ServerDocumentPickerModuleAssembly: ServerDocumentPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ServerConfigurationModuleAssemblyProtocol
    
    func make() -> AnyView {
        ServerDocumentPickerView(
            model: ServerDocumentPickerViewModel(storage: self.serviceLocator.serverConfigurationStorage())
        ).eraseToAnyView()
    }
}
