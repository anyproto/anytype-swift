import Foundation
import SwiftUI
import AnytypeCore

protocol AboutModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: AboutModuleOutput?) -> UIViewController
}

final class AboutModuleAssembly: AboutModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - AboutModuleAssemblyProtocol
    
    @MainActor
    func make(output: AboutModuleOutput?) -> UIViewController {
        let model = AboutViewModel(
            middlewareConfigurationProvider: serviceLocator.middlewareConfigurationProvider(),
            accountManager: serviceLocator.accountManager(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            output: output
        )
        let view = AboutView(model: model)
        return UIHostingController(rootView: view)
    }
}
